#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PDF_DIR="$DIST_DIR/pdf"
CHAPTER_PDF_DIR="$PDF_DIR/chapters"

CHAPTER_LIST_NULL="$BUILD_DIR/chapter_list.null"
CHAPTER_LIST="$DIST_DIR/chapter_list.txt"

MERGED_PDF="$PDF_DIR/PCIe_Technology_3.0_Chinese_merged.pdf"
CHAPTER_ZIP="$DIST_DIR/PCIe_Technology_3.0_Chinese_chapters_pdf.zip"
RELEASE_NOTES="$DIST_DIR/release_notes.md"

mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PDF_DIR" "$CHAPTER_PDF_DIR"

echo "清理旧构建产物..."
rm -f "$CHAPTER_LIST_NULL" "$CHAPTER_LIST" "$MERGED_PDF" "$CHAPTER_ZIP" "$RELEASE_NOTES"
rm -f "$CHAPTER_PDF_DIR"/*.pdf 2>/dev/null || true

echo "检查依赖..."
command -v pandoc >/dev/null 2>&1 || {
  echo "错误：没有找到 pandoc"
  exit 1
}

command -v xelatex >/dev/null 2>&1 || {
  echo "错误：没有找到 xelatex"
  exit 1
}

command -v pdfunite >/dev/null 2>&1 || {
  echo "错误：没有找到 pdfunite"
  echo "Ubuntu 可安装：sudo apt-get install poppler-utils"
  exit 1
}

command -v zip >/dev/null 2>&1 || {
  echo "错误：没有找到 zip"
  exit 1
}

echo "生成章节列表..."

# 只选择根目录下数字开头的 md：
# 1 背景.md
# 2 PCIe 体系结构概述.md
# ...
# 22 术语表.md
find "$ROOT_DIR" \
  -maxdepth 1 \
  -type f \
  -regextype posix-extended \
  -regex '.*/[0-9]+.*\.md' \
  -printf '%f\0' \
  | sort -z -V \
  > "$CHAPTER_LIST_NULL"

if [[ ! -s "$CHAPTER_LIST_NULL" ]]; then
  echo "错误：没有找到数字开头的章节 md 文件"
  exit 1
fi

tr '\0' '\n' < "$CHAPTER_LIST_NULL" > "$CHAPTER_LIST"

echo "本次参与构建的章节："
cat "$CHAPTER_LIST"
echo

echo "开始生成每章 PDF..."

PDF_FILES=()

while IFS= read -r -d '' md_name; do
  md_path="$ROOT_DIR/$md_name"
  base="${md_name%.md}"
  out_pdf="$CHAPTER_PDF_DIR/${base}.pdf"

  echo "转换：$md_name"
  echo "  -> $out_pdf"

  pandoc "$md_path" \
    -f markdown+raw_html+tex_math_dollars \
    --resource-path="$ROOT_DIR:$ROOT_DIR/img:$ROOT_DIR/docs" \
    --pdf-engine=xelatex \
    -V documentclass=ctexart \
    -V CJKmainfont="Noto Serif CJK SC" \
    -V mainfont="Noto Serif CJK SC" \
    -V monofont="Noto Sans Mono CJK SC" \
    -V geometry:margin=2cm \
    -V colorlinks=true \
    -V linkcolor=blue \
    -V urlcolor=blue \
    --toc \
    --toc-depth=3 \
    --number-sections \
    -o "$out_pdf"

  PDF_FILES+=("$out_pdf")
done < "$CHAPTER_LIST_NULL"

echo
echo "合并所有章节 PDF..."
printf '  %s\n' "${PDF_FILES[@]}"

pdfunite "${PDF_FILES[@]}" "$MERGED_PDF"

echo
echo "打包单章 PDF..."
(
  cd "$PDF_DIR"
  zip -r "$CHAPTER_ZIP" "chapters"
)

echo "生成 Release notes..."

{
  echo "# PCI Express Technology 3.0 中文版 PDF 自动构建"
  echo
  echo "本 Release 由 GitHub Actions 自动生成。"
  echo
  echo "## 附件说明"
  echo
  echo "- \`PCIe_Technology_3.0_Chinese_merged.pdf\`：由每章 PDF 合并而成的整本 PDF"
  echo "- \`PCIe_Technology_3.0_Chinese_chapters_pdf.zip\`：每章单独 PDF"
  echo "- \`chapter_list.txt\`：本次参与构建的章节列表"
  echo
  echo "## 构建方式"
  echo
  echo "每个章节 Markdown 单独生成 PDF，并带有本章目录；最后使用 pdfunite 合并所有章节 PDF。"
  echo
  echo "## 章节列表"
  echo
  sed 's/^/- /' "$CHAPTER_LIST"
  echo
  echo "## 版权说明"
  echo
  echo "本翻译仅用于学习使用。原书版权归 Mindshare 所有。"
} > "$RELEASE_NOTES"

echo
echo "构建完成。"
echo "整本合并 PDF：$MERGED_PDF"
echo "单章 PDF 压缩包：$CHAPTER_ZIP"
echo "章节列表：$CHAPTER_LIST"
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PDF_DIR="$DIST_DIR/pdf"
CHAPTER_PDF_DIR="$PDF_DIR/chapters"

FULL_MD="$BUILD_DIR/all_generated.md"
CHAPTER_LIST="$BUILD_DIR/chapter_list.txt"

FULL_PDF="$PDF_DIR/PCIe_Technology_3.0_Chinese_full.pdf"
CHAPTER_ZIP="$DIST_DIR/PCIe_Technology_3.0_Chinese_chapters_pdf.zip"

RELEASE_NOTES="$DIST_DIR/release_notes.md"

mkdir -p "$BUILD_DIR" "$PDF_DIR" "$CHAPTER_PDF_DIR"

echo "清理旧构建产物..."
rm -f "$FULL_MD" "$CHAPTER_LIST" "$FULL_PDF" "$CHAPTER_ZIP" "$RELEASE_NOTES"
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

command -v zip >/dev/null 2>&1 || {
  echo "错误：没有找到 zip"
  exit 1
}

echo "生成章节文件列表..."

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
  > "$BUILD_DIR/chapter_list.null"

if [[ ! -s "$BUILD_DIR/chapter_list.null" ]]; then
  echo "错误：没有找到数字开头的章节 md 文件"
  exit 1
fi

tr '\0' '\n' < "$BUILD_DIR/chapter_list.null" > "$CHAPTER_LIST"

echo "本次参与合并的章节："
cat "$CHAPTER_LIST"
echo

echo "自动生成整本 Markdown：$FULL_MD"

{
  echo "---"
  echo "title: PCI Express Technology 3.0 中文版"
  echo "author: yakoye"
  echo "lang: zh-CN"
  echo "---"
  echo

  while IFS= read -r -d '' md_name; do
    md_path="$ROOT_DIR/$md_name"

    echo
    echo "<!-- source: $md_name -->"
    echo

    cat "$md_path"

    echo
    echo
    echo '\newpage'
    echo
  done < "$BUILD_DIR/chapter_list.null"
} > "$FULL_MD"

echo "生成整本 PDF：$FULL_PDF"

pandoc "$FULL_MD" \
  -f gfm+raw_html+raw_tex+tex_math_dollars \
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
  -o "$FULL_PDF"

echo "生成单章 PDF..."

while IFS= read -r -d '' md_name; do
  md_path="$ROOT_DIR/$md_name"
  base="${md_name%.md}"
  out_pdf="$CHAPTER_PDF_DIR/${base}.pdf"

  echo "转换章节：$md_name"

  pandoc "$md_path" \
    -f gfm+raw_html+raw_tex+tex_math_dollars \
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
done < "$BUILD_DIR/chapter_list.null"

echo "打包单章 PDF：$CHAPTER_ZIP"

(
  cd "$PDF_DIR"
  zip -r "$CHAPTER_ZIP" "chapters"
)

cp "$FULL_MD" "$DIST_DIR/all_generated.md"
cp "$CHAPTER_LIST" "$DIST_DIR/chapter_list.txt"

echo "生成 Release notes：$RELEASE_NOTES"

{
  echo "# PCI Express Technology 3.0 中文版 PDF 自动构建"
  echo
  echo "本 Release 由 GitHub Actions 自动生成。"
  echo
  echo "## 附件说明"
  echo
  echo "- \`PCIe_Technology_3.0_Chinese_full.pdf\`：整本 PDF"
  echo "- \`PCIe_Technology_3.0_Chinese_chapters_pdf.zip\`：每章单独 PDF"
  echo "- \`all_generated.md\`：自动合并生成的 Markdown"
  echo "- \`chapter_list.txt\`：本次参与构建的章节列表"
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
echo "整本 PDF：$FULL_PDF"
echo "章节 ZIP：$CHAPTER_ZIP"
echo "合并 MD：$DIST_DIR/all_generated.md"
echo "章节列表：$DIST_DIR/chapter_list.txt"
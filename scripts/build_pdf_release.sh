#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PDF_DIR="$DIST_DIR/pdf"
CHAPTER_PDF_DIR="$PDF_DIR/chapters"
TMP_DIR="$BUILD_DIR/pdf_tmp"

CHAPTER_LIST_NULL="$BUILD_DIR/chapter_list.null"
CHAPTER_LIST="$DIST_DIR/chapter_list.txt"

MERGED_PDF="$PDF_DIR/PCIe_Technology_3.0_Chinese_merged.pdf"
CHAPTER_ZIP="$DIST_DIR/PCIe_Technology_3.0_Chinese_chapters_pdf.zip"
RELEASE_NOTES="$DIST_DIR/release_notes.md"

mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PDF_DIR" "$CHAPTER_PDF_DIR" "$TMP_DIR"

echo "清理旧构建产物..."
rm -f "$CHAPTER_LIST_NULL" "$CHAPTER_LIST" "$MERGED_PDF" "$CHAPTER_ZIP" "$RELEASE_NOTES"
rm -f "$CHAPTER_PDF_DIR"/*.pdf 2>/dev/null || true
rm -f "$TMP_DIR"/* 2>/dev/null || true

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

# 将 LaTeX 特殊字符简单转义，避免标题里有 & % 等出问题
escape_latex() {
  local s="$1"
  s="${s//\\/\\textbackslash{}}"
  s="${s//&/\\&}"
  s="${s//%/\\%}"
  s="${s//\$/\\$}"
  s="${s//#/\\#}"
  s="${s//_/\\_}"
  s="${s//\{/\\{}"
  s="${s//\}/\\}}"
  echo "$s"
}

PDF_FILES=()

echo "开始生成每章 PDF..."

while IFS= read -r -d '' md_name; do
  md_path="$ROOT_DIR/$md_name"
  base="${md_name%.md}"
  out_pdf="$CHAPTER_PDF_DIR/${base}.pdf"

  # 章标题：默认直接用文件名（去掉 .md）
  chapter_title="$base"
  chapter_title_tex="$(escape_latex "$chapter_title")"

  tmp_md="$TMP_DIR/${base}.merged.md"
  tmp_header="$TMP_DIR/${base}.header.tex"

  echo "转换：$md_name"
  echo "  -> $out_pdf"

  # 1) 生成每章临时 md（前面加封面）
  cat > "$tmp_md" <<EOF
---
title: "$chapter_title"
lang: zh-CN
---

\\begin{titlepage}
\\thispagestyle{empty}
\\centering
\\vspace*{0.22\\textheight}

{\\Huge\\bfseries $chapter_title_tex\\par}

\\vspace{1.2cm}

{\\Large PCI Express Technology 3.0 中文版\\par}

\\vfill

{\\large yakoye\\par}
{\\large 自动构建 PDF\\par}

\\end{titlepage}

\\clearpage

EOF

  cat "$md_path" >> "$tmp_md"

  # 2) 生成每章页眉控制
  cat > "$tmp_header" <<EOF
\\usepackage{fancyhdr}
\\usepackage{hyperref}

\\hypersetup{
  colorlinks=true,
  linkcolor=blue,
  urlcolor=blue,
  citecolor=blue,
  linktoc=all,
  bookmarksopen=true,
  bookmarksnumbered=false
}

\\pagestyle{fancy}
\\fancyhf{}
\\fancyhead[C]{\\small $chapter_title_tex}
\\renewcommand{\\headrulewidth}{0.4pt}
\\renewcommand{\\footrulewidth}{0pt}

\\fancypagestyle{plain}{
  \\fancyhf{}
  \\fancyhead[C]{\\small $chapter_title_tex}
  \\renewcommand{\\headrulewidth}{0.4pt}
  \\renewcommand{\\footrulewidth}{0pt}
}
EOF

  # 3) 转单章 PDF
  # 注意：
  # - 去掉 --number-sections，避免目录重复编号
  # - 保留 --toc，让每章有自己的目录
  pandoc "$tmp_md" \
    -f markdown+raw_html+raw_tex+tex_math_dollars \
    --resource-path="$ROOT_DIR:$ROOT_DIR/img:$ROOT_DIR/docs" \
    --pdf-engine=xelatex \
    -V documentclass=ctexart \
    -V CJKmainfont="Noto Serif CJK SC" \
    -V mainfont="Noto Serif CJK SC" \
    -V monofont="Noto Sans Mono CJK SC" \
    -V geometry:margin=2cm \
    --toc \
    --toc-depth=4 \
    -H "$tmp_header" \
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
  echo "## 当前构建特性"
  echo
  echo "- 每章 PDF 带封面"
  echo "- 每章 PDF 带目录"
  echo "- 页眉显示本章标题"
  echo "- 页脚不显示页码"
  echo "- 不启用章节自动编号，避免目录编号重复"
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
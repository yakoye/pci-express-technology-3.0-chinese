#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PDF_DIR="$DIST_DIR/pdf"
CHAPTER_PDF_DIR="$PDF_DIR/chapters"
TMP_DIR="$BUILD_DIR/pdf_tmp"

CHAPTER_LIST_NULL="$BUILD_DIR/chapter_list.null"
CHAPTER_LIST_TXT="$DIST_DIR/chapter_list.txt"

MERGED_PDF="$PDF_DIR/PCIe_Technology_3.0_Chinese_merged.pdf"
CHAPTER_ZIP="$DIST_DIR/PCIe_Technology_3.0_Chinese_chapters_pdf.zip"
RELEASE_NOTES="$DIST_DIR/release_notes.md"

MASTER_TEX="$TMP_DIR/master.tex"
MASTER_JOBNAME="master_book"

mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PDF_DIR" "$CHAPTER_PDF_DIR" "$TMP_DIR"

echo "清理旧构建产物..."
rm -f "$CHAPTER_LIST_NULL" "$CHAPTER_LIST_TXT" "$MERGED_PDF" "$CHAPTER_ZIP" "$RELEASE_NOTES"
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

command -v zip >/dev/null 2>&1 || {
  echo "错误：没有找到 zip"
  exit 1
}

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
  s="${s//^/\\textasciicircum{}}"
  s="${s//~/\\textasciitilde{}}"
  echo "$s"
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

tr '\0' '\n' < "$CHAPTER_LIST_NULL" > "$CHAPTER_LIST_TXT"

echo "本次参与构建的章节："
cat "$CHAPTER_LIST_TXT"
echo

echo "开始生成每章 PDF..."

declare -a CHAPTER_TITLES
declare -a CHAPTER_PDFS

idx=0

while IFS= read -r -d '' md_name; do
  idx=$((idx + 1))

  md_path="$ROOT_DIR/$md_name"
  base="${md_name%.md}"

  # 为了最终 master.tex 引用更稳，章节 pdf 用安全文件名
  chapter_pdf="$CHAPTER_PDF_DIR/chapter_$(printf "%02d" "$idx").pdf"

  chapter_title="$base"
  chapter_title_tex="$(escape_latex "$chapter_title")"

  tmp_md="$TMP_DIR/chapter_$(printf "%02d" "$idx").md"
  tmp_header="$TMP_DIR/chapter_$(printf "%02d" "$idx").header.tex"

  echo "转换：$md_name"
  echo "  -> $chapter_pdf"

  # ---------- 1) 生成更美观的章节封面 ----------
  cat > "$tmp_md" <<EOF
---
title: "$chapter_title"
lang: zh-CN
---

\\begin{titlepage}
\\thispagestyle{empty}
\\centering

\\vspace*{0.10\\textheight}

{\\Large\\bfseries PCI Express Technology 3.0 中文版\\par}

\\vspace{1.0cm}

{\\rule{0.82\\textwidth}{0.8pt}\\par}

\\vspace{1.2cm}

{\\Huge\\bfseries $chapter_title_tex\\par}

\\vspace{1.2cm}

{\\rule{0.82\\textwidth}{0.8pt}\\par}

\\vspace{1.8cm}

{\\Large 技术学习资料 / 自动构建章节 PDF\\par}

\\vfill

{\\large 作者整理：yakoye\\par}
\\vspace{0.4cm}
{\\large 构建时间：\\today\\par}

\\end{titlepage}

\\clearpage

EOF

  cat "$md_path" >> "$tmp_md"

  # ---------- 2) 每章页眉 / 超链接 ----------
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

  # ---------- 3) 生成每章 PDF ----------
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
    -o "$chapter_pdf"

  CHAPTER_TITLES+=("$chapter_title")
  CHAPTER_PDFS+=("$chapter_pdf")
done < "$CHAPTER_LIST_NULL"

echo
echo "开始生成整本 merged.pdf 的独立总封面 + 总目录 + 章节合并..."

# ---------- 4) 生成 master.tex ----------
cat > "$MASTER_TEX" <<'EOF'
\documentclass[UTF8]{ctexbook}

\usepackage[a4paper,margin=2cm]{geometry}
\usepackage{hyperref}
\usepackage{pdfpages}
\usepackage{xcolor}
\usepackage{fancyhdr}

\hypersetup{
  colorlinks=true,
  linkcolor=blue,
  urlcolor=blue,
  citecolor=blue,
  linktoc=all,
  bookmarksopen=true,
  bookmarksnumbered=true
}

\pagestyle{empty}
\setcounter{tocdepth}{1}

\begin{document}
EOF

# ---------- 总封面 ----------
cat >> "$MASTER_TEX" <<'EOF'
\begin{titlepage}
\thispagestyle{empty}
\centering

\vspace*{0.10\textheight}

{\Huge\bfseries PCI Express Technology 3.0 \par}
\vspace{0.5cm}
{\Huge\bfseries 中文版 \par}

\vspace{1.2cm}
{\rule{0.84\textwidth}{1pt}\par}

\vspace{1.5cm}
{\LARGE\bfseries 技术学习与阅读版本 \par}

\vspace{1.0cm}
{\Large 自动构建整本 PDF \par}

\vfill

{\Large 整理者：yakoye \par}
\vspace{0.4cm}
{\large 构建日期：\today \par}

\vspace{1.2cm}
{\rule{0.84\textwidth}{1pt}\par}

\vspace{0.8cm}
{\large 本资料仅用于学习交流，原书版权归 Mindshare 所有。 \par}

\end{titlepage}

\clearpage

\pdfbookmark[0]{目录}{main-toc}
\tableofcontents
\clearpage
EOF

# ---------- 章节插入 ----------
chapter_count=${#CHAPTER_TITLES[@]}

for ((i=0; i<chapter_count; i++)); do
  title="${CHAPTER_TITLES[$i]}"
  pdf="${CHAPTER_PDFS[$i]}"

  # 绝对路径给 LaTeX，避免相对路径出错
  pdf_abs="$(realpath "$pdf")"
  title_tex="$(escape_latex "$title")"

  cat >> "$MASTER_TEX" <<EOF
\includepdf[
  pages=-,
  pagecommand={},
  addtotoc={1,chapter,1,{$title_tex},chapter:$((i+1))}
]{${pdf_abs}}
EOF
done

cat >> "$MASTER_TEX" <<'EOF'

\end{document}
EOF

# ---------- 5) 编译整本 PDF（两遍，保证目录完整） ----------
(
  cd "$TMP_DIR"
  xelatex -interaction=nonstopmode -halt-on-error "$MASTER_TEX"
  xelatex -interaction=nonstopmode -halt-on-error "$MASTER_TEX"
)

# xelatex 默认输出在当前目录，文件名是 master.pdf
cp "$TMP_DIR/master.pdf" "$MERGED_PDF"

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
  echo "- \`PCIe_Technology_3.0_Chinese_merged.pdf\`：整本 PDF（含总封面、总目录）"
  echo "- \`PCIe_Technology_3.0_Chinese_chapters_pdf.zip\`：每章单独 PDF"
  echo "- \`chapter_list.txt\`：本次参与构建的章节列表"
  echo
  echo "## 当前构建特性"
  echo
  echo "- 每章 PDF 带美化封面"
  echo "- 每章 PDF 带目录"
  echo "- 每章页眉显示本章标题"
  echo "- 每章不显示页码"
  echo "- 整本 merged.pdf 带独立总封面"
  echo "- 整本 merged.pdf 带总目录"
  echo "- merged.pdf 可在多数阅读器中显示目录 / 书签 / 大纲"
  echo
  echo "## 章节列表"
  echo
  sed 's/^/- /' "$CHAPTER_LIST_TXT"
  echo
  echo "## 版权说明"
  echo
  echo "本翻译仅用于学习使用。原书版权归 Mindshare 所有。"
} > "$RELEASE_NOTES"

echo
echo "构建完成。"
echo "整本合并 PDF：$MERGED_PDF"
echo "单章 PDF 压缩包：$CHAPTER_ZIP"
echo "章节列表：$CHAPTER_LIST_TXT"
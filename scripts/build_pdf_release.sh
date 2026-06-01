#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PDF_DIR="$DIST_DIR/pdf"
CHAPTER_PDF_DIR="$PDF_DIR/chapters"
TMP_DIR="$BUILD_DIR/pdf_tmp"

CHAPTER_LIST_TXT="$DIST_DIR/chapter_list.txt"
FULL_BOOK_MD="$TMP_DIR/full_book.md"

FULL_BOOK_PDF="$PDF_DIR/PCIe_Technology_3.0_Chinese_merged.pdf"
CHAPTER_ZIP="$DIST_DIR/PCIe_Technology_3.0_Chinese_chapters_pdf.zip"
RELEASE_NOTES="$DIST_DIR/release_notes.md"

mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PDF_DIR" "$CHAPTER_PDF_DIR" "$TMP_DIR"

echo "清理旧构建产物..."
rm -f "$CHAPTER_LIST_TXT" "$FULL_BOOK_PDF" "$CHAPTER_ZIP" "$RELEASE_NOTES"
rm -f "$CHAPTER_PDF_DIR"/*.pdf 2>/dev/null || true
rm -f "$TMP_DIR"/* 2>/dev/null || true

echo "检查依赖..."
command -v pandoc >/dev/null 2>&1 || { echo "错误：没有找到 pandoc"; exit 1; }
command -v xelatex >/dev/null 2>&1 || { echo "错误：没有找到 xelatex"; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "错误：没有找到 zip"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "错误：没有找到 python3"; exit 1; }

chapters=(
"1 背景.md|第 1 章|背景|Background"
"2 PCIe 体系结构概述.md|第 2 章|PCIe 体系结构概述|PCIe Architecture Overview"
"3 PCIe 配置概述.md|第 3 章|PCIe 配置概述|PCIe Configuration Overview"
"4 地址空间与事务路由.md|第 4 章|地址空间与事务路由|Address Spaces and Transaction Routing"
"5 TLP 元素.md|第 5 章|TLP 元素|TLP Elements"
"6 流量控制.md|第 6 章|流量控制|Flow Control"
"7 QoS 服务质量.md|第 7 章|QoS 服务质量|Quality of Service"
"8 事务排序.md|第 8 章|事务排序|Transaction Ordering"
"9 DLLP 元素.md|第 9 章|DLLP 元素|DLLP Elements"
"10 Ack-Nak_协议.md|第 10 章|Ack/Nak 协议|Ack/Nak Protocol"
"11 物理层-逻辑_Gen1和Gen2.md|第 11 章|物理层-逻辑（Gen1 和 Gen2）|Physical Layer Logic: Gen1 and Gen2"
"12 物理层-逻辑(gen3).md|第 12 章|物理层-逻辑（Gen3）|Physical Layer Logic: Gen3"
"13 物理层-电气特性.md|第 13 章|物理层-电气特性|Physical Layer Electrical Characteristics"
"14 链路初始化与训练.md|第 14 章|链路初始化与训练|Link Initialization and Training"
"15 错误检测与处理.md|第 15 章|错误检测与处理|Error Detection and Handling"
"16 电源管理.md|第 16 章|电源管理|Power Management"
"17 中断支持.md|第 17 章|中断支持|Interrupt Support"
"18 系统复位.md|第 18 章|系统复位|System Reset"
"19 热插拔和功耗预算管理.md|第 19 章|热插拔和功耗预算管理|Hot-Plug and Power Budget Management"
"20 规范2.1版本更新.md|第 20 章|规范 2.1 版本更新|PCIe 2.1 Specification Updates"
"21 附录.md|第 21 章|附录|Appendices"
"22 术语表.md|第 22 章|术语表|Glossary"
)

latex_escape() {
  python3 - "$1" <<'PY'
import sys

s = sys.argv[1]
mapping = {
    "\\": r"\textbackslash{}",
    "&": r"\&",
    "%": r"\%",
    "$": r"\$",
    "#": r"\#",
    "_": r"\_",
    "{": r"\{",
    "}": r"\}",
    "~": r"\textasciitilde{}",
    "^": r"\textasciicircum{}",
}
print("".join(mapping.get(ch, ch) for ch in s))
PY
}

normalize_md_to_stdout() {
  python3 - "$1" <<'PY'
import sys
from pathlib import Path

p = Path(sys.argv[1])
text = p.read_text(encoding="utf-8", errors="ignore")

text = text.replace("\u02ba", '"')
text = text.replace("\u02b9", "'")
text = text.replace("\x00", "")

print(text)
PY
}

echo "生成章节列表..."

: > "$CHAPTER_LIST_TXT"

declare -a CHAPTER_FILES
declare -a CHAPTER_LABELS
declare -a CHAPTER_CN_TITLES
declare -a CHAPTER_EN_TITLES

for item in "${chapters[@]}"; do
  md_name="$(echo "$item" | cut -d'|' -f1)"
  chapter_label="$(echo "$item" | cut -d'|' -f2)"
  chapter_cn="$(echo "$item" | cut -d'|' -f3)"
  chapter_en="$(echo "$item" | cut -d'|' -f4)"

  if [[ ! -f "$ROOT_DIR/$md_name" ]]; then
    echo "跳过缺失文件：$md_name"
    continue
  fi

  CHAPTER_FILES+=("$md_name")
  CHAPTER_LABELS+=("$chapter_label")
  CHAPTER_CN_TITLES+=("$chapter_cn")
  CHAPTER_EN_TITLES+=("$chapter_en")

  echo "$md_name" >> "$CHAPTER_LIST_TXT"
done

if [[ "${#CHAPTER_FILES[@]}" -eq 0 ]]; then
  echo "错误：没有找到可构建的章节 md 文件"
  exit 1
fi

echo "本次参与构建的章节："
cat "$CHAPTER_LIST_TXT"
echo

chapter_count="${#CHAPTER_FILES[@]}"

# ------------------------------------------------------------
# 公共 LaTeX header
# ------------------------------------------------------------
COMMON_HEADER="$TMP_DIR/common_header.tex"

cat > "$COMMON_HEADER" <<'EOF'
\usepackage{xcolor}
\usepackage{fancyhdr}
\usepackage{float}
\usepackage{placeins}
\usepackage{flafter}
\usepackage{graphicx}
\usepackage{bookmark}
\usepackage{etoolbox}

\definecolor{pcieblue}{HTML}{163A5F}
\definecolor{pciegold}{HTML}{A17835}
\definecolor{pciegray}{HTML}{555555}

\AtBeginDocument{
  \hypersetup{
    colorlinks=true,
    linkcolor=blue,
    urlcolor=blue,
    citecolor=blue,
    linktoc=all,
    bookmarksopen=true,
    bookmarksnumbered=false,
    pdfauthor={yakoye},
    pdftitle={PCI Express Technology 3.0 中文版}
  }
}

% 图片尽量不要浮动到很后面
\floatplacement{figure}{H}
\makeatletter
\def\fps@figure{H}
\makeatother

% 图片默认限制宽度，避免溢出页面
\setkeys{Gin}{width=\linewidth,keepaspectratio}

% 全书页眉页脚
\pagestyle{fancy}
\fancyhf{}
\fancyhead[C]{\small PCI Express Technology 3.0 中文版}
\fancyfoot[C]{\small \thepage}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0pt}

\fancypagestyle{plain}{
  \fancyhf{}
  \fancyfoot[C]{\small \thepage}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
}
EOF

# ------------------------------------------------------------
# 1. 生成单章 PDF
# 单章 PDF 仍保留本章目录，适合单独下载。
# ------------------------------------------------------------
echo "开始生成每章 PDF..."

for ((i=0; i<chapter_count; i++)); do
  md_name="${CHAPTER_FILES[$i]}"
  chapter_label="${CHAPTER_LABELS[$i]}"
  chapter_cn="${CHAPTER_CN_TITLES[$i]}"
  chapter_en="${CHAPTER_EN_TITLES[$i]}"

  chapter_index="$(printf "%02d" "$((i + 1))")"
  chapter_pdf="$CHAPTER_PDF_DIR/chapter_${chapter_index}.pdf"

  tmp_md="$TMP_DIR/chapter_${chapter_index}.md"
  tmp_before="$TMP_DIR/chapter_${chapter_index}.before.tex"
  tmp_header="$TMP_DIR/chapter_${chapter_index}.header.tex"

  chapter_label_tex="$(latex_escape "$chapter_label")"
  chapter_cn_tex="$(latex_escape "$chapter_cn")"
  chapter_en_tex="$(latex_escape "$chapter_en")"
  md_name_tex="$(latex_escape "$md_name")"

  chapter_no="$(echo "$chapter_label" | grep -oE '[0-9]+' | head -n 1)"
  header_title="${chapter_no} ${chapter_cn}"
  header_title_tex="$(latex_escape "$header_title")"

  echo "转换单章：$md_name"
  echo "  -> $chapter_pdf"

  cat > "$tmp_md" <<EOF
---
lang: zh-CN
---

EOF

  normalize_md_to_stdout "$ROOT_DIR/$md_name" >> "$tmp_md"

  cat > "$tmp_before" <<EOF
\\begin{titlepage}
\\thispagestyle{empty}
\\centering

\\vspace*{0.13\\textheight}

{\\color{pcieblue}\\rule{0.80\\textwidth}{1.2pt}\\par}

\\vspace{1.3cm}

{\\Large\\bfseries\\color{pciegold} $chapter_label_tex\\par}

\\vspace{0.85cm}

{\\Huge\\bfseries\\color{pcieblue} $chapter_cn_tex\\par}

\\vspace{0.55cm}

{\\Large\\itshape\\color{pciegray} $chapter_en_tex\\par}

\\vspace{1.2cm}

{\\color{pcieblue}\\rule{0.54\\textwidth}{0.6pt}\\par}

\\vfill

{\\small Source: $md_name_tex\\par}

\\vspace{1.1cm}

{\\large yakoye\\par}
\\vspace{0.25cm}
{\\large \\today\\par}

\\end{titlepage}

\\clearpage

\\begin{center}
{\\Large\\bfseries $chapter_label_tex\\quad $chapter_cn_tex\\par}
\\end{center}

\\vspace{0.6cm}

\\renewcommand{\\contentsname}{目录}
EOF

  cat > "$tmp_header" <<EOF
\\input{$COMMON_HEADER}

\\pagestyle{fancy}
\\fancyhf{}
\\fancyhead[C]{\\small $header_title_tex}
\\fancyfoot[C]{\\small \\thepage}
\\renewcommand{\\headrulewidth}{0.4pt}
\\renewcommand{\\footrulewidth}{0pt}

\\fancypagestyle{plain}{
  \\fancyhf{}
  \\fancyfoot[C]{\\small \\thepage}
  \\renewcommand{\\headrulewidth}{0pt}
  \\renewcommand{\\footrulewidth}{0pt}
}
EOF

  pandoc "$tmp_md" \
    -f markdown+raw_html+raw_tex+tex_math_dollars-implicit_figures \
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
    -V linktoc=all \
    --toc \
    --toc-depth=4 \
    -B "$tmp_before" \
    -H "$tmp_header" \
    -o "$chapter_pdf"
done

# ------------------------------------------------------------
# 2. 生成整本 Markdown
# 这一步是关键：整本 PDF 由 Markdown 一次性生成，
# 所以目录点击、书签、页码都是全局正确的。
# ------------------------------------------------------------
echo
echo "生成整本 Markdown：$FULL_BOOK_MD"

cat > "$FULL_BOOK_MD" <<'EOF'
---
lang: zh-CN
---

\begin{titlepage}
\thispagestyle{empty}

\begin{center}

\vspace*{0.08\textheight}

{\Large\scshape Technical Reading Edition \par}

\vspace{1.0cm}

{\color{pcieblue}\rule{0.86\textwidth}{1.4pt}\par}

\vspace{1.2cm}

{\Huge\bfseries\color{pcieblue} PCI Express\par}

\vspace{0.35cm}

{\Huge\bfseries\color{pcieblue} Technology 3.0\par}

\vspace{0.8cm}

{\Huge\bfseries 中文版\par}

\vspace{1.2cm}

{\color{pciegold}\rule{0.56\textwidth}{0.8pt}\par}

\vspace{1.0cm}

{\LARGE\bfseries PCIe 技术学习与离线阅读版本\par}

\vspace{0.45cm}

{\Large Architecture · Configuration · Transaction · Link · Power · Interrupt\par}

\vfill

\begin{minipage}{0.72\textwidth}
\centering
{\large 本 PDF 由 GitHub Actions 自动构建生成。 \par}
\vspace{0.25cm}
{\large 内容来源于仓库 Markdown 章节文件。 \par}
\vspace{0.25cm}
{\large 适合长期归档、离线阅读和技术检索。 \par}
\end{minipage}

\vfill

{\Large 整理者：yakoye\par}

\vspace{0.35cm}

{\large 构建日期：\today\par}

\vspace{0.8cm}

{\color{pcieblue}\rule{0.86\textwidth}{1.4pt}\par}

\vspace{0.55cm}

{\small 本资料仅用于学习交流，原书版权归 Mindshare 所有。\par}

\end{center}

\end{titlepage}

\clearpage

\renewcommand{\contentsname}{目录}
\tableofcontents
\clearpage

EOF

for ((i=0; i<chapter_count; i++)); do
  md_name="${CHAPTER_FILES[$i]}"
  chapter_label="${CHAPTER_LABELS[$i]}"
  chapter_cn="${CHAPTER_CN_TITLES[$i]}"
  chapter_en="${CHAPTER_EN_TITLES[$i]}"

  chapter_label_tex="$(latex_escape "$chapter_label")"
  chapter_cn_tex="$(latex_escape "$chapter_cn")"
  chapter_en_tex="$(latex_escape "$chapter_en")"
  md_name_tex="$(latex_escape "$md_name")"

  cat >> "$FULL_BOOK_MD" <<EOF

\\clearpage

\\begin{titlepage}
\\thispagestyle{empty}
\\centering

\\vspace*{0.13\\textheight}

{\\color{pcieblue}\\rule{0.80\\textwidth}{1.2pt}\\par}

\\vspace{1.3cm}

{\\Large\\bfseries\\color{pciegold} $chapter_label_tex\\par}

\\vspace{0.85cm}

{\\Huge\\bfseries\\color{pcieblue} $chapter_cn_tex\\par}

\\vspace{0.55cm}

{\\Large\\itshape\\color{pciegray} $chapter_en_tex\\par}

\\vspace{1.2cm}

{\\color{pcieblue}\\rule{0.54\\textwidth}{0.6pt}\\par}

\\vfill

{\\small Source: $md_name_tex\\par}

\\vspace{1.1cm}

{\\large yakoye\\par}
\\vspace{0.25cm}
{\\large \\today\\par}

\\end{titlepage}

\\clearpage

EOF

  normalize_md_to_stdout "$ROOT_DIR/$md_name" >> "$FULL_BOOK_MD"
  echo >> "$FULL_BOOK_MD"
done

# ------------------------------------------------------------
# 3. 一次性生成整本 PDF
# ------------------------------------------------------------
echo
echo "生成整本 PDF：$FULL_BOOK_PDF"

FULL_HEADER="$TMP_DIR/full_book_header.tex"

cat > "$FULL_HEADER" <<EOF
\\input{$COMMON_HEADER}
EOF

pandoc "$FULL_BOOK_MD" \
  -f markdown+raw_html+raw_tex+tex_math_dollars-implicit_figures \
  --resource-path="$ROOT_DIR:$ROOT_DIR/img:$ROOT_DIR/docs" \
  --pdf-engine=xelatex \
  -V documentclass=ctexbook \
  -V CJKmainfont="Noto Serif CJK SC" \
  -V mainfont="Noto Serif CJK SC" \
  -V monofont="Noto Sans Mono CJK SC" \
  -V geometry:margin=2cm \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -V linktoc=all \
  -V secnumdepth=-2 \
  -H "$FULL_HEADER" \
  -o "$FULL_BOOK_PDF"

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
  echo "- \`PCIe_Technology_3.0_Chinese_merged.pdf\`：整本 PDF，由所有 Markdown 一次性生成，目录页码和跳转为全局正确"
  echo "- \`PCIe_Technology_3.0_Chinese_chapters_pdf.zip\`：每章单独 PDF"
  echo "- \`chapter_list.txt\`：本次参与构建的章节列表"
  echo
  echo "## 当前构建特性"
  echo
  echo "- 整本 PDF 不再由单章 PDF 拼接生成"
  echo "- 整本目录可点击跳转"
  echo "- 整本目录页码为全局页码"
  echo "- 整本 PDF 页码统一"
  echo "- 单章 PDF 仍单独生成，便于下载"
  echo "- 图片尽量保持在 Markdown 原始位置附近"
  echo "- 取消自动章节编号，避免和原文标题编号重复"
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
echo "整本 PDF：$FULL_BOOK_PDF"
echo "单章 PDF 压缩包：$CHAPTER_ZIP"
echo "章节列表：$CHAPTER_LIST_TXT"
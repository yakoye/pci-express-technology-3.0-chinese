#!/usr/bin/env bash
set -e

mkdir -p docs/assets

chapters=(
"1 背景.md|第 1 章 背景"
"2 PCIe 体系结构概述.md|第 2 章 PCIe 体系结构概述"
"3 PCIe 配置概述.md|第 3 章 PCIe 配置概述"
"4 地址空间与事务路由.md|第 4 章 地址空间与事务路由"
"5 TLP 元素.md|第 5 章 TLP 元素"
"6 流量控制.md|第 6 章 流量控制"
"7 QoS 服务质量.md|第 7 章 QoS 服务质量"
"8 事务排序.md|第 8 章 事务排序"
"9 DLLP 元素.md|第 9 章 DLLP 元素"
"10 Ack-Nak_协议.md|第 10 章 Ack/Nak 协议"
"11 物理层-逻辑_Gen1和Gen2.md|第 11 章 物理层-逻辑（Gen1 和 Gen2）"
"12 物理层-逻辑(gen3).md|第 12 章 物理层-逻辑（Gen3）"
"13 物理层-电气特性.md|第 13 章 物理层-电气特性"
"14 链路初始化与训练.md|第 14 章 链路初始化与训练"
"15 错误检测与处理.md|第 15 章 错误检测与处理"
"16 电源管理.md|第 16 章 电源管理"
"17 中断支持.md|第 17 章 中断支持"
"18 系统复位.md|第 18 章 系统复位"
"19 热插拔和功耗预算管理.md|第 19 章 热插拔和功耗预算管理"
"20 规范2.1版本更新.md|第 20 章 规范 2.1 版本更新"
"21 附录.md|第 21 章 附录"
"22 术语表.md|术语表"
)

total=${#chapters[@]}

for ((i=0; i<total; i++)); do
  item="${chapters[$i]}"
  md="${item%%|*}"
  title="${item#*|}"

  if [ ! -f "$md" ]; then
    echo "Skip missing file: $md"
    continue
  fi

  html="${md%.md}.html"

  prev_url=""
  prev_title=""
  next_url=""
  next_title=""

  if [ "$i" -gt 0 ]; then
    prev_item="${chapters[$((i-1))]}"
    prev_md="${prev_item%%|*}"
    prev_title="${prev_item#*|}"
    prev_url="${prev_md%.md}.html"
  fi

  if [ "$i" -lt $((total-1)) ]; then
    next_item="${chapters[$((i+1))]}"
    next_md="${next_item%%|*}"
    next_title="${next_item#*|}"
    next_url="${next_md%.md}.html"
  fi

  echo "Building: $md -> docs/$html"

  pandoc "$md" \
    -f markdown \
    -t html5 \
    --standalone \
    --toc \
    --toc-depth=4 \
    --template=docs/template.html \
    --metadata title="$title" \
    -V prev_url="$prev_url" \
    -V prev_title="$prev_title" \
    -V next_url="$next_url" \
    -V next_title="$next_title" \
    -o "docs/$html"
done

echo "Done."

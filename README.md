
# PCI Express Technology 3.0 中文版

---

## 项目简介

本仓库是对 MindShare 经典书籍 **《PCI Express Technology: Comprehensive Guide to Generations 1.x, 2.x and 3.0》** 的中文学习整理版。

项目基于开源翻译仓库 [Chinese-Translation-of-PCI-Express-Technology-](https://github.com/ljgibbslf/Chinese-Translation-of-PCI-Express-Technology-) 继续修订、补充和排版，目标是形成一份更适合中文读者阅读、检索、离线归档和工程学习的 PCIe 技术资料。

本项目重点覆盖 PCIe Gen1 / Gen2 / Gen3 的体系结构、配置空间、TLP、DLLP、流量控制、事务排序、链路训练、电源管理、错误处理、中断、复位、热插拔等核心内容。

---

## 阅读入口

| 类型            | 链接                                                                                                 | 说明                               |
| --------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------- |
| 在线网页        | [📖 GitHub Pages 在线阅读](https://yakoye.github.io/pci-express-technology-3.0-chinese/docs/index.html) | 适合浏览器阅读，支持章节跳转       |
| Markdown 源文档 | [仓库源码](https://github.com/yakoye/pci-express-technology-3.0-chinese)                                | 适合版本管理、检索和二次修订       |
| PDF 版本        | [Releases 下载](https://github.com/yakoye/pci-express-technology-3.0-chinese/releases)                  | 自动构建整本 PDF 与单章 PDF 压缩包 |

---

## 项目特性

### 1. Markdown 源文档

所有章节均以 Markdown 形式维护，便于：

* 版本管理；
* 内容校对；
* 文本检索；
* 后续排版与自动化转换；
* 生成 HTML / PDF 等多种格式。

### 2. GitHub Pages 在线阅读

仓库中的章节 Markdown 会通过自动化构建生成 HTML 页面，并发布到 GitHub Pages。

在线版本支持：

* 章节目录；
* 上一章 / 下一章导航；
* 浏览器阅读；
* 移动端与桌面端访问；
* 适合快速查阅。

### 3. 自动化 PDF 构建

项目支持通过 GitHub Actions 自动生成 PDF 版本，包括：

* 整本 PDF；
* 单章 PDF；
* 单章 PDF 压缩包；
* 自动生成 Release 附件；
* PDF 封面；
* 总目录；
* 书签 / 大纲；
* 页码；
* 图片居中与尺寸约束；
* 图片说明与图片尽量保持在同一页。

整本 PDF 由 Markdown 一次性生成，目录页码和跳转为全局正确；单章 PDF 仍单独生成，便于按章节下载。

### 4. 面向工程学习的排版整理

本项目不是简单机翻文本，而是对原始翻译内容进行持续整理，包括：

* 术语统一；
* 章节排版；
* 图片位置调整；
* 标题层级修正；
* 表格与列表格式修正；
* 中英文表达校对；
* PDF 与 HTML 阅读体验优化。

---

## 章节目录

| 章节 | 标题                        | Markdown                                                                                                                                            |
| ---: | --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
|    1 | 背景                        | [1 背景.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/1%20%E8%83%8C%E6%99%AF.md)                                                                                           |
|    2 | PCIe 体系结构概述           | [2 PCIe 体系结构概述.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/2%20PCIe%20%E4%BD%93%E7%B3%BB%E7%BB%93%E6%9E%84%E6%A6%82%E8%BF%B0.md)                                   |
|    3 | PCIe 配置概述               | [3 PCIe 配置概述.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/3%20PCIe%20%E9%85%8D%E7%BD%AE%E6%A6%82%E8%BF%B0.md)                                                         |
|    4 | 地址空间与事务路由          | [4 地址空间与事务路由.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/4%20%E5%9C%B0%E5%9D%80%E7%A9%BA%E9%97%B4%E4%B8%8E%E4%BA%8B%E5%8A%A1%E8%B7%AF%E7%94%B1.md)              |
|    5 | TLP 元素                    | [5 TLP 元素.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/5%20TLP%20%E5%85%83%E7%B4%A0.md)                                                                                 |
|    6 | 流量控制                    | [6 流量控制.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/6%20%E6%B5%81%E9%87%8F%E6%8E%A7%E5%88%B6.md)                                                                     |
|    7 | QoS 服务质量                | [7 QoS 服务质量.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/7%20QoS%20%E6%9C%8D%E5%8A%A1%E8%B4%A8%E9%87%8F.md)                                                           |
|    8 | 事务排序                    | [8 事务排序.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/8%20%E4%BA%8B%E5%8A%A1%E6%8E%92%E5%BA%8F.md)                                                                     |
|    9 | DLLP 元素                   | [9 DLLP 元素.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/9%20DLLP%20%E5%85%83%E7%B4%A0.md)                                                                               |
|   10 | Ack/Nak 协议                | [10 Ack-Nak_协议.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/10%20Ack-Nak_%E5%8D%8F%E8%AE%AE.md)                                                                         |
|   11 | 物理层-逻辑（Gen1 和 Gen2） | [11 物理层-逻辑_Gen1和Gen2.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/11%20%E7%89%A9%E7%90%86%E5%B1%82-%E9%80%BB%E8%BE%91_Gen1%E5%92%8CGen2.md)                         |
|   12 | 物理层-逻辑（Gen3）         | [12 物理层-逻辑(gen3).md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/12%20%E7%89%A9%E7%90%86%E5%B1%82-%E9%80%BB%E8%BE%91%28gen3%29.md)                                      |
|   13 | 物理层-电气特性             | [13 物理层-电气特性.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/13%20%E7%89%A9%E7%90%86%E5%B1%82-%E7%94%B5%E6%B0%94%E7%89%B9%E6%80%A7.md)                                |
|   14 | 链路初始化与训练            | [14 链路初始化与训练.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/14%20%E9%93%BE%E8%B7%AF%E5%88%9D%E5%A7%8B%E5%8C%96%E4%B8%8E%E8%AE%AD%E7%BB%83.md)                       |
|   15 | 错误检测与处理              | [15 错误检测与处理.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/15%20%E9%94%99%E8%AF%AF%E6%A3%80%E6%B5%8B%E4%B8%8E%E5%A4%84%E7%90%86.md)                                  |
|   16 | 电源管理                    | [16 电源管理.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/16%20%E7%94%B5%E6%BA%90%E7%AE%A1%E7%90%86.md)                                                                   |
|   17 | 中断支持                    | [17 中断支持.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/17%20%E4%B8%AD%E6%96%AD%E6%94%AF%E6%8C%81.md)                                                                   |
|   18 | 系统复位                    | [18 系统复位.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/18%20%E7%B3%BB%E7%BB%9F%E5%A4%8D%E4%BD%8D.md)                                                                   |
|   19 | 热插拔和功耗预算管理        | [19 热插拔和功耗预算管理.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/19%20%E7%83%AD%E6%8F%92%E6%8B%94%E5%92%8C%E5%8A%9F%E8%80%97%E9%A2%84%E7%AE%97%E7%AE%A1%E7%90%86.md) |
|   20 | 规范 2.1 版本更新           | [20 规范2.1版本更新.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/20%20%E8%A7%84%E8%8C%832.1%E7%89%88%E6%9C%AC%E6%9B%B4%E6%96%B0.md)                                       |
|   21 | 附录                        | [21 附录.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/21%20%E9%99%84%E5%BD%95.md)                                                                                         |
|   22 | 术语表                      | [22 术语表.md](https://github.com/yakoye/pci-express-technology-3.0-chinese/blob/main/22%20%E6%9C%AF%E8%AF%AD%E8%A1%A8.md)                                                                              |

---

## 仓库结构

```text
.
├── 1 背景.md
├── 2 PCIe 体系结构概述.md
├── ...
├── 22 术语表.md
├── docs/
│   ├── index.html
│   ├── template.html
│   └── *.html
├── img/
│   └── 图片资源
├── translation_guidelines/
│   └── 翻译与校对参考
├── scripts/
│   └── build_pdf_release.sh
├── build_pages.sh
├── README.md
└── LICENSE
```

---

## 自动化构建

本项目使用 GitHub Actions 维护两类自动构建流程。

### HTML 页面构建

修改章节 Markdown、HTML 模板或构建脚本后，GitHub Actions 会自动执行：

```bash
bash build_pages.sh
```

并将生成后的 HTML 页面写入 `docs/` 目录，用于 GitHub Pages 在线阅读。

### PDF Release 构建

PDF 构建流程会自动执行：

```bash
bash scripts/build_pdf_release.sh
```

生成内容包括：

```text
dist/pdf/PCIe_Technology_3.0_Chinese_merged.pdf
dist/PCIe_Technology_3.0_Chinese_chapters_pdf.zip
dist/chapter_list.txt
```

其中：

* `PCIe_Technology_3.0_Chinese_merged.pdf`：整本 PDF；
* `PCIe_Technology_3.0_Chinese_chapters_pdf.zip`：每章单独 PDF；
* `chapter_list.txt`：本次参与构建的章节列表。

---

## 本地构建

### 生成 HTML

本地需要安装 `pandoc`。

```bash
bash build_pages.sh
```

生成结果位于：

```text
docs/
```

### 生成 PDF

本地需要安装：

* `pandoc`
* `xelatex`
* 中文字体，例如 Noto CJK
* `zip`

Ubuntu / WSL 可参考：

```bash
sudo apt-get update
sudo apt-get install -y \
  pandoc \
  texlive-xetex \
  texlive-latex-extra \
  texlive-lang-chinese \
  fonts-noto-cjk \
  zip
```

执行：

```bash
bash scripts/build_pdf_release.sh
```

生成结果位于：

```text
dist/
```

---

## 维护进度

待完成的工作：

章节二次校对，日常问题修正。

当前已经完成的主要工作：

* 第 10 章翻译、排版、校对；
* 第 11 章翻译、排版、校对；
* 第 13 章翻译、排版、校对；
* 第 14 章校对；
* 第 15 章翻译、排版、校对；
* 第 16 章翻译、排版、校对；
* 第 17 章翻译、排版、校对；
* 第 18 章翻译、排版、校对；
* 第 19 章翻译、排版、校对；
* 第 20 章翻译、排版、校对；
* 第 21 章翻译、排版、校对；
* 术语表翻译、排版、校对；
* HTML 在线阅读自动构建；
* PDF 自动构建与 Release 输出。

---

## 更新记录

| 日期       | 记录                                                                                    |
| ---------- | --------------------------------------------------------------------------------------- |
| 2026.06.01 | 完成自动化 PDF 构建                                                                     |
| 2026.05.25 | 完成第 10、11、13、14、15、16、17、18、19、20、21 章与术语表校对；完成第 1~9 章排版调整 |
| 2026.05.22 | 完成第 19 章翻译                                                                        |
| 2026.05.13 | 完成第 20 章排版                                                                        |
| 2026.05.12 | 完成第 10、11、17 章排版                                                                |
| 2026.05.11 | 完成第 15、16、18 章排版                                                                |
| 2026.05.09 | 完成第 13 章排版                                                                        |
| 2026.05.08 | 完成第 10、11、13、15、16、17、18、20、21 章与术语表翻译                                |

---

## 翻译与修订说明

本项目内容经历了翻译、排版、校对和格式修订。部分内容曾借助翻译工具与大模型辅助处理，后续进行人工整理与校对。

使用过的辅助工具包括：

* 沉浸式翻译；
* PDF Pro 功能；
* DeepSeek-V4-Flash；
* ChatGPT 校对与排版辅助。

本项目会持续修订术语、格式、图片位置、PDF 阅读体验和网页阅读体验。

---

## 贡献方式

欢迎通过以下方式参与：

* 提交 Issue：指出翻译、术语、排版、链接、图片、PDF 或 HTML 问题；
* 提交 Pull Request：修订内容、补充说明、优化脚本；
* 参与术语统一：帮助完善 PCIe 相关中英文术语；
* 改进阅读体验：优化网页模板、PDF 样式、构建流程。

提交建议时，最好注明：

```text
章节：
位置：
原文：
建议修改：
理由：
```

---

## 版权说明

原书版权归 MindShare 所有：

> 《PCI Express Technology: Comprehensive Guide to Generations 1.x, 2.x and 3.0》

原书页面：

* [https://www.mindshare.com/Books/Titles/PCI_Express_Technology_3.0](https://www.mindshare.com/Books/Titles/PCI_Express_Technology_3.0)

本项目仅用于个人学习、技术研究和交流，不用于商业用途，也不代表原作者或出版社的官方译本。

如涉及版权问题，请通过 Issue 联系处理。

---

## License

本仓库代码、脚本和排版构建部分遵循仓库内 `LICENSE` 文件。

原书内容版权归原作者及出版方所有。

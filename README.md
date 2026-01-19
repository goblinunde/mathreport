# MindFlow LaTeX Class

![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![LaTeX](https://img.shields.io/badge/XeLaTeX-required-red.svg)

**MindFlow** 是一个专为**数学（泛函分析/PDE）**与**深度学习**研究设计的现代 LaTeX 类文件。提供三种文档模式、**十种 Section 样式**（含极客/美化风格）、丰富的数学宏库和美观的环境设计。

---

## 📂 项目结构

```text
mathreport/
├── mindflow.cls          # [核心] 类文件定义 (~1800行)
├── mindflow_demo.tex     # 核心功能演示
├── mathnotes.tex         # Note 模式示例 (学术笔记)
├── mathbook.tex          # Book 模式示例 (技术书籍)
├── mathreport.tex        # Report 模式示例 (实验报告+审稿)
├── figure/               # 图片资源
├── fonts/                # (可选) 自定义字体
├── Makefile              # 构建脚本
├── build.sh              # Shell 构建脚本
└── README.md             
```

---

## 🚀 快速开始

### 编译命令

```bash
# 推荐：并行编译（利用多核）
make parallel

# 单独编译
make notes      # mathnotes.pdf
make book       # mathbook.pdf
make report     # mathreport.pdf

# 快速预览（单次编译）
make quick

# 清理
make clean      # 保留 PDF
make cleanall   # 删除所有生成文件
```

### Shell 脚本

```bash
./build.sh --help           # 查看帮助
./build.sh -q notes book    # 快速编译多个文档
./build.sh -p all           # 并行编译所有
./build.sh -v demo          # 编译并打开 PDF
./build.sh --check          # 检查环境
./build.sh -w               # 监视文件变化自动编译
```

---

## ⚙️ 类选项详解

### 文档模式 (三选一)

| 选项 | 基类 | 用途 | 章节结构 |
|------|------|------|----------|
| `note` | ctexart | 日常笔记、论文阅读 | `\section` |
| `book` | ctexbook | 系统书籍、学位论文 | `\chapter` + `\section` |
| `report` | ctexrep | 实验报告、项目总结 | `\section` (类 chapter 样式) |

### Section 样式 (十选一)

#### 基础样式

| 选项 | 效果 |
|------|------|
| `secstyle-classic` | 🔵 蓝色编号块 + 浅蓝背景 (默认) |
| `secstyle-modern` | 📊 大号编号 + 渐变底边线 |
| `secstyle-minimal` | 📝 极简左侧竖线 + 纯文本 |
| `secstyle-boxed` | 📦 边框卡片 + 投影阴影 |

#### 极客/美化样式

| 选项 | 效果 |
|------|------|
| `secstyle-neon` | 🟢 霓虹发光：深色底 + 青绿光边 (赛博朋克) |
| `secstyle-terminal` | 🖥️ 终端风格：黑底绿字 + 命令提示符 (Hacker) |
| `secstyle-gradient` | 🌈 渐变背景：蓝紫渐变 + 白色文字 (科技感) |
| `secstyle-elegant` | ✨ 金色典雅：装饰线 + 居中排版 (学术风) |
| `secstyle-blueprint` | 📐 蓝图网格：深蓝底 + 工程坐标标记 |
| `secstyle-ribbon` | 🎗️ 折叠丝带：红色丝带装饰 + 阴影层次 |

### 其他选项

| 选项 | 说明 |
|------|------|
| `linux` / `mac` / `win` | 平台字体配置 |
| `review` | 启用行号显示 (审稿模式) |
| `chapnum` / `nochapnum` | 章节编号 / 全局连续编号 |

### 使用示例

```latex
% Note 模式 + 霓虹样式 (赛博朋克风)
\documentclass[linux, note, secstyle-neon]{mindflow}

% Book 模式 + 终端样式 (Hacker 风)
\documentclass[linux, book, secstyle-terminal]{mindflow}

% Report 模式 + 蓝图样式 (工程师风) + 审稿
\documentclass[linux, report, secstyle-blueprint, review]{mindflow}
```

---

## 📝 特殊命令

### 目录命令

```latex
\mftableofcontents  % 目录使用罗马数字，正文从第1页开始
```

### 水印命令

```latex
\mfWatermarkText{DRAFT}                 % 默认灰色水印
\mfWatermarkText[red!15][6]{绝密}       % 自定义颜色和大小
\mfWatermarkImage{figure/logo.png}      % 图片水印
```

### 批注命令

```latex
\todo{待完成内容}      % 橙色边框
\fixme{需要修正}       % 红色边框
\notebox{备注说明}     % 蓝色边框
```

---

## 🧮 数学宏库

### 微分与积分

| 宏 | 输出 | 说明 |
|----|------|------|
| `\pd{u}{t}` | ∂u/∂t | 偏导数 |
| `\pdd{u}{x}` | ∂²u/∂x² | 二阶偏导 |
| `\dx`, `\dt`, `\dmu` | dx, dt, dμ | 微分元 |
| `\intO` | ∫_Ω | 区域积分 |
| `\intpO` | ∫_{∂Ω} | 边界积分 |

### Sobolev 空间

| 宏 | 输出 |
|----|------|
| `\Lp{p}` | Lᵖ |
| `\Hk{k}` | Hᵏ |
| `\Wkp{k}{p}` | W^{k,p} |
| `\normL{f}` | ‖f‖_{Lᵖ} |

### 深度学习

| 宏 | 说明 |
|----|------|
| `\loss`, `\MSE`, `\CE` | 损失函数 |
| `\relu`, `\softmax`, `\sigmoid` | 激活函数 |
| `\param`, `\model`, `\data` | 模型符号 |
| `\vect{x}`, `\weight`, `\bias` | 向量/权重 |

---

## 🎨 环境一览

### 定理环境 (tcolorbox 风格)

```latex
\begin{theoremnew}{定理名称}
    定理内容...
\end{theoremnew}

\begin{defnnew}{定义名称}
    定义内容...
\end{defnnew}

\begin{lemmanew}{引理}  \begin{proofnew}  \begin{corollarynew}  \begin{remarknew}
```

### 提示框环境

```latex
\begin{notice}{标题}  内容  \end{notice}   % 信息提示
\begin{tip}{标题}     内容  \end{tip}      % 技巧建议
\begin{warning}{标题} 内容  \end{warning}  % 警告
\begin{conclusion}{标题} 内容 \end{conclusion}  % 总结
```

### 导读/总结框

```latex
\begin{introbox}[本章导读]
    章节开头的导读内容...
\end{introbox}

\begin{summarybox}[本章小结]
    章节结尾的总结...
\end{summarybox}
```

### 代码环境

```latex
\begin{codeblock}[python]{标题}
import torch
...
\end{codeblock}
```

### 图文混排

```latex
\begin{textfigure}[right]{path/to/image.png}{图片标题}
    文字描述内容...
\end{textfigure}

\begin{parallelfigures}{总标题}
    \addfig[0.45]{img1.png}{子标题1}
    \addfig[0.45]{img2.png}{子标题2}
\end{parallelfigures}

\begin{figurerow}{标题}[3]
    \figitem{img1.png}{描述1}
    \figitem{img2.png}{描述2}
    \figitem{img3.png}{描述3}
\end{figurerow}
```

---

## 🛠️ Makefile 命令速查

| 命令 | 说明 |
|------|------|
| `make all` | 串行编译所有文档 |
| `make parallel` | 并行编译 (推荐) |
| `make demo` | 编译 mindflow_demo.pdf |
| `make notes` | 编译 mathnotes.pdf |
| `make book` | 编译 mathbook.pdf |
| `make report` | 编译 mathreport.pdf |
| `make quick` | 快速编译 (单次) |
| `make clean` | 清理临时文件 |
| `make cleanall` | 完全清理 |
| `make check` | 检查编译环境 |
| `make view` | 编译并打开 PDF |
| `make watch` | 监视文件变化 |
| `make dist` | 打包发布 |
| `make help` | 显示帮助 |

---

## 📋 环境要求

- **编译器**: XeLaTeX (TeX Live 2020+)
- **必需包**: ctex, tcolorbox, tikz, pgfplots, physics, siunitx, listings, hyperref
- **可选工具**: inotify-tools (用于 `make watch`)

### 环境检查

```bash
make check
# 或
./build.sh --check
```

---

## 📝 许可证

MIT License - 自由使用、修改和分发。

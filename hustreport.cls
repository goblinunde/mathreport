% =========================================================
% HUST Report Template Class
% 文件名: hustreport.cls
% 说明: 黑龙江科技大学社会调查报告/实习报告专用模板类
% 版本: v2.13 (Modular Refactor)
% 日期: 2025/02/20
% =========================================================

% ---------------------------------------------------------
% 0. 版本与格式声明
% ---------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hustreport}[2026/01/05 v3.0 HUST Report Class]


% ---------------------------------------------------------
% 1. 核心选项与基类加载
% ---------------------------------------------------------
% [新增] 定义系统平台与字体模式开关
\newif\ifhust@oswin    \hust@oswinfalse
\newif\ifhust@osmac    \hust@osmacfalse
\newif\ifhust@oslinux  \hust@oslinuxfalse
\newif\ifhust@optfonts \hust@optfontsfalse % 新增 fonts 显式开关
\newif\ifhust@thesis   \hust@thesisfalse   % 💡 毕业论文模式开关

% [新增] 声明参数选项
\DeclareOption{win}{\hust@oswintrue}
\DeclareOption{mac}{\hust@osmactrue}
\DeclareOption{linux}{\hust@oslinuxtrue}
\DeclareOption{fonts}{\hust@optfontstrue} % 开启本地字体优先模式
\DeclareOption{thesis}{\hust@thesistrue}  % 💡 启用毕业论文页眉模式

% 传递所有未定义的选项给底层类
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexrep}}
\ProcessOptions\relax

% 加载 ctexrep 基类
% [参数说明]
% a4paper: A4纸张
% UTF8: 编码格式
% zihao=-4: 正文默认小四号字
% linespread=1.5: 默认 1.5 倍行距
\LoadClass[a4paper,UTF8,zihao=-4,linespread=1.5]{ctexrep}



% ---------------------------------------------------------
% 2. 宏包加载 (按功能分类)
% ---------------------------------------------------------

% [2.1] 页面与布局
\RequirePackage{geometry}   % 页面边距设置
\RequirePackage{fancyhdr}   % 页眉页脚定制
\RequirePackage{float}      % 浮动体控制 (H参数)
\RequirePackage[sort&compress,numbers,square]{natbib} % 参考文献管理

% [2.2] 标题与目录
\RequirePackage{titletoc}   % 目录格式定制
\RequirePackage{titlesec}   % 章节标题格式定制

% [2.3] 数学与物理
\RequirePackage{amsmath,amssymb,amsfonts,amsthm} % 数学公式核心包
\RequirePackage{physics}    % 物理符号便捷包
\RequirePackage{siunitx}    % 国际单位制支持
\RequirePackage{newtxmath}  % 数学字体优化
\RequirePackage{calc}       % 长度计算支持

% [2.4] 图形与颜色
\RequirePackage{graphicx}   % 图片插入
\RequirePackage{subcaption} % 子图支持
\RequirePackage{tikz}       % 绘图与绝对定位(用于封面Logo)
\RequirePackage[dvipsnames, svgnames, x11names]{xcolor} % 颜色支持

% [2.5] 表格与列表
\RequirePackage{booktabs}   % 三线表支持
\RequirePackage{threeparttable} 
\RequirePackage{caption} 
\RequirePackage{tabularx}   % 自适应宽度表格
\RequirePackage{xltabular} % <--- 必须添加这个宏包，用于支持跨页长表格
\RequirePackage{multirow}   % 表格多行合并
\RequirePackage{makecell}   % 表格单元格换行
\RequirePackage{array}      % 表格列格式扩展
\RequirePackage{enumitem}   % 列表环境定制
\RequirePackage{diagbox}
% [2.6] 字体与修饰
\RequirePackage{anyfontsize} % 任意字号支持 % 下划线支持 (normalem防止em被重定义为下划线)

% [2.7] 超链接与PDF属性
\RequirePackage{hyperref}   % 超链接支持

% ---------------------------------------------------------
% 3. 信息接口定义 (用户填写的变量)
% ---------------------------------------------------------
\makeatletter % 开启内部命令模式

% [3.1] 内部存储变量定义
\newcommand{\@major}{}      % 专业
\newcommand{\@dept}{}       % 院系
\newcommand{\@advisor}{}    % 指导教师
\newcommand{\@team}{}       % 队员
\newcommand{\@studentID}{}  % 学号
\newcommand{\@reportID}{}   % 报告编号

% [3.2] 对外接口命令
\newcommand{\major}[1]{\def\@major{#1}}
\newcommand{\dept}[1]{\def\@dept{#1}}
\newcommand{\advisor}[1]{\def\@advisor{#1}}
\newcommand{\team}[1]{\def\@team{#1}}
\newcommand{\studentID}[1]{\def\@studentID{#1}}
\newcommand{\reportID}[1]{\def\@reportID{#1}}

% [3.3] 任务书专用变量
\newcommand{\taskTargetText}{内容待定}
\newcommand{\taskContentText}{内容待定}
\newcommand{\taskExpectedText}{内容待定}
\newcommand{\taskScheduleText}{进度待定}

% [3.4] 自适应下划线组件 (用于填空处)
\newcommand{\ulineinfo}[2][280pt]{%
	\begin{minipage}[t]{#1}%
		\centering\zihao{3}\songti\uline{#2\hfill}%
	\end{minipage}%
}

% ---------------------------------------------------------
% 4. 字体配置 (智能检测 + 多平台适配 + 伪粗体优化)
% ---------------------------------------------------------
% 清除旧定义
\let\songti\relax
\let\heiti\relax
\let\kaiti\relax

% ---------------------------------------------------------
% 逻辑优先级说明：
% 1. [最高优先级] 本地 fonts/ 目录存在：
%    无论参数如何，只要有文件，强制使用本地文件以保证一致性。
%    如果用户显式指定了 [fonts] 但没文件，会发出警告。
% 2. [参数优先] win -> Windows 系统字体 (自动开启伪粗体)
% 3. [参数优先] mac -> macOS 系统字体
% 4. [保底策略] linux 或 默认 -> Fandol 开源字体
% ---------------------------------------------------------

% 检查本地字体文件的核心标识
% 逻辑更新：分别检测中英文字体，实现混合加载模式

% --- 4.1 英文字体配置 ---
\IfFileExists{fonts/times.ttf}{
    % [本地] 发现本地 Times 字体 (文件名匹配实际列表: times.ttf, timesbd.ttf...)
    \typeout{>> [HUST Report] Local English fonts found (fonts/times.ttf).}
    \setmainfont{times.ttf}[
        Path = fonts/,
        BoldFont = timesbd.ttf,
        ItalicFont = timesi.ttf,
        BoldItalicFont = timesbi.ttf
    ]
}{
    % [系统] 未发现本地字体，使用系统回退
    \ifhust@oswin
        \setmainfont{Times New Roman}
    \else
        \ifhust@osmac
            \setmainfont{Times New Roman}
        \else
            \setmainfont{TeX Gyre Termes}
        \fi
    \fi
}

% --- 4.2 中文字体配置 ---
% 优先检测 fonts/SimSun.ttf
\IfFileExists{fonts/SimSun.ttf}{
    % [本地] 发现本地宋体
    \typeout{>> [HUST Report] Local Chinese fonts found (fonts/SimSun.ttf).}
    \defaultfontfeatures{Ligatures=TeX}
    
    % 预判字体文件是否存在，确定字体参数
    \IfFileExists{fonts/SimHei.ttf}{%
        \def\hust@cjk@bold{SimHei.ttf}%
        \def\hust@cjk@fakebold{false}%
    }{%
        \def\hust@cjk@bold{SimSun.ttf}%
        \def\hust@cjk@fakebold{2.5}%
    }%
    
    \IfFileExists{fonts/KaiTi.ttf}{%
        \def\hust@cjk@italic{KaiTi.ttf}%
    }{%
        \def\hust@cjk@italic{SimSun.ttf}%
    }%
    
    % 主字体设置
    \setCJKmainfont{SimSun.ttf}[
        Path = fonts/,
        BoldFont = \hust@cjk@bold,
        ItalicFont = \hust@cjk@italic,
        AutoFakeBold = \hust@cjk@fakebold
    ]
    
    % 配套字体设置
    \IfFileExists{fonts/SimHei.ttf}{
        \setCJKsansfont{SimHei.ttf}[Path = fonts/]
        \newCJKfontfamily\heiti{SimHei.ttf}[Path=fonts/]
    }{
        \setCJKsansfont{SimSun.ttf}[Path = fonts/, AutoFakeBold=2.5]
        \newCJKfontfamily\heiti{SimSun.ttf}[Path=fonts/, AutoFakeBold=2.5]
    }
    
    \IfFileExists{fonts/KaiTi.ttf}{
        \setCJKmonofont{KaiTi.ttf}[Path = fonts/]
        \newCJKfontfamily\kaiti{KaiTi.ttf}[Path=fonts/]
    }{
        \setCJKmonofont{SimSun.ttf}[Path = fonts/, AutoFakeBold=2.5]
        \newCJKfontfamily\kaiti{SimSun.ttf}[Path=fonts/, AutoFakeBold=2.5]
    }
    
    \newCJKfontfamily\songti{SimSun.ttf}[Path=fonts/, AutoFakeBold=2.5]

}{
    % [系统] 未发现本地宋体，执行系统回退逻辑
    \ifhust@oswin
        % Windows
        \typeout{>> [HUST Report] Using Windows system fonts.}
        \setCJKmainfont[BoldFont=SimHei,ItalicFont=KaiTi,AutoFakeBold=2.5]{SimSun}
        \setCJKsansfont[AutoFakeBold=2.5]{SimHei}
        \setCJKmonofont[AutoFakeBold=2.5]{KaiTi}
        \newCJKfontfamily\songti{SimSun}[BoldFont=SimHei,ItalicFont=KaiTi,AutoFakeBold=2.5]
        \newCJKfontfamily\heiti{SimHei}[AutoFakeBold=2.5]
        \newCJKfontfamily\kaiti{KaiTi}[AutoFakeBold=2.5]
    \else
    \ifhust@osmac
        % macOS
        \typeout{>> [HUST Report] Using macOS system fonts.}
        \setCJKmainfont[BoldFont=Heiti SC Medium,ItalicFont=Kaiti SC,AutoFakeBold=2.0]{Songti SC Light}
        \setCJKsansfont[AutoFakeBold=2.0]{Heiti SC Medium}
        \setCJKmonofont[AutoFakeBold=2.0]{Kaiti SC}
        \newCJKfontfamily\songti{Songti SC Light}[BoldFont=Heiti SC Medium,ItalicFont=Kaiti SC, AutoFakeBold=2.0]
        \newCJKfontfamily\heiti{Heiti SC Medium}
        \newCJKfontfamily\kaiti{Kaiti SC}
    \else
        % Linux / Default (Fandol)
        \typeout{>> [HUST Report] Using Fandol fonts (Linux/Fallback).}
        \setCJKmainfont[
            Extension=.otf,
            BoldFont=FandolHei-Regular,
            ItalicFont=FandolKai-Regular
        ]{FandolSong-Regular}
        \setCJKsansfont[Extension=.otf]{FandolHei-Regular}
        \setCJKmonofont[Extension=.otf]{FandolKai-Regular}
        \newCJKfontfamily\songti[Extension=.otf]{FandolSong-Regular}
        \newCJKfontfamily\heiti[Extension=.otf]{FandolHei-Regular}
        \newCJKfontfamily\kaiti[Extension=.otf]{FandolKai-Regular}
    \fi
    \fi
}

% ---------------------------------------------------------
% 5. 页面布局与计数器设置
% ---------------------------------------------------------
% [5.1] 页面边距与页眉配置 (按模式切换)
\ifhust@thesis
    % 💡 毕业论文模式：使用特殊页眉和更大的 top margin
    \geometry{
        a4paper,
        top=3.7cm,
        bottom=2.5cm,
        left=3.9cm,
        right=2.5cm,
        headheight=3cm,
        headsep=0.5cm
    }
    
    % 配置 fancyhdr 页眉
    \pagestyle{fancy}
    \fancyhf{} % 清除默认页眉页脚
    
    % 页眉分隔线宽度
    \renewcommand{\headrulewidth}{2.5pt}
    
    % 左侧：校徽 Logo
    \fancyhead[L]{%
        \raisebox{-0.2cm}{\includegraphics[height=2.6cm]{logo.png}}%
    }
    
    % 中间：校名图片 + "毕业论文"字样
    \fancyhead[C]{%
        \raisebox{0.5cm}{%
            \begin{tabular}{c}
                \includegraphics[height=1.2cm]{ustc.png} \\[-2pt]
                {\zihao{2}\heiti 毕\hspace{2.05em}业\hspace{2.05em}论\hspace{2.05em}文}
            \end{tabular}%
        }%
    }
    
    % 页脚：页码居中
    \fancyfoot[C]{\thepage}
    
\else
    % 💡 普通报告模式：使用简洁的页面设置
    \geometry{left=3.017cm, right=3.017cm, top=2.54cm, bottom=2.54cm, headheight=15pt}
    \pagestyle{plain} % 页码位于底部居中
\fi

% [5.2] 计数器逻辑与层级绑定
% 保持底层计数器为阿拉伯数字
\renewcommand{\thesection}{\arabic{section}}
\renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
\renewcommand{\thesubsubsection}{\thesubsection.\arabic{subsubsection}}

% [重要] 建立编号绑定关系：实现 (章-序号) 且每章自动重置为 1
% 必须在导言区使用 \counterwithin (需要 LaTeX 2018+ 或 chngcntr 宏包)
\counterwithin{equation}{section}
\counterwithin{figure}{section}
\counterwithin{table}{section}

% [5.3] 目录深度设置 (显示到三级标题)
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{3}


% ---------------------------------------------------------
% 6. 章节标题与目录样式
% ---------------------------------------------------------

% [6.1] 章节标题样式 (ctexset)
\ctexset{
	% 一级标题 (Section/章) -> "第一章"
	section = {
		number = \chinese{section}, % 强制转中文数字
		name = {第,章},             % 前后缀
		format = \centering\zihao{3}\heiti\bfseries, % 三号黑体加粗居中
		aftername = \quad,
		beforeskip = 15pt,
		afterskip = 20pt,
		fixskip = true
	},
	% 二级标题 (Subsection/节) -> "1.1"
	subsection = {
		name = {},
		number = \thesubsection,
		format = \zihao{4}\heiti\bfseries, % 四号黑体加粗
		aftername = \hspace{1em},
		afterskip = 1ex
	},
	% 三级标题 (Subsubsection/小节) -> "1.1.1"
	subsubsection = {
		name = {},
		number = \thesubsubsection,
		format = \zihao{-4}\songti, % 小四号宋体
		aftername = \hspace{1em},
		afterskip = 1ex
	}
}

% [6.2] 目录样式 (titletoc)
% ---------------------------------------------------------

% 章 (Section)
\titlecontents{section}[0pt]
{\addvspace{6pt}\bfseries\heiti\zihao{4}} % 格式
{\thecontentslabel\quad}                  % 标签
{}                                        % 无标签时的格式
{\titlerule*[0.5pc]{.}\contentspage}      % 引导线和页码

% 节 (Subsection)
\titlecontents{subsection}[2em]
{\songti\zihao{-4}}
{\thecontentslabel\quad}
{}
{\titlerule*[0.5pc]{.}\contentspage}

% 小节 (Subsubsection)
\titlecontents{subsubsection}[4em]
{\songti\zihao{-4}}
{\thecontentslabel\quad}
{}
{\titlerule*[0.5pc]{.}\contentspage}


% ---------------------------------------------------------
% 7. 图表、公式与引用样式 (高级配置)
% ---------------------------------------------------------
\setkeys{Gin}{draft=false} % 强制显示图片

% [7.1] 浮动体参数优化 (解决图片乱跑问题)
% 允许顶部浮动体占据页面的 85% (默认 70%)
\renewcommand{\topfraction}{0.85}
% 允许底部浮动体占据页面的 70% (默认 30%)
\renewcommand{\bottomfraction}{0.70}
% 文本页中，文本至少要占 10% (默认 20%)，意味着图片可以占 90%
\renewcommand{\textfraction}{0.10}
% 浮动页中，图片至少要占 50% 才能独立成页
\renewcommand{\floatpagefraction}{0.50}

% [7.2] Caption 样式 (整合长表格支持)
\DeclareCaptionFont{heiti}{\heiti}
\DeclareCaptionFont{fivehao}{\zihao{5}}
\captionsetup{
	format=hang,        % 悬挂缩进
	labelsep=quad,      % 标签与内容间的空格
	font={fivehao,heiti},      % 字体设置
	labelfont={fivehao,heiti}, % 标签字体
	textfont={fivehao,heiti},  % 内容字体
	skip=6pt            % 标题与图表的间距
}
\captionsetup[sub]{labelformat=simple}

% 针对长表格 (longtable/xltabular) 的特殊设置
% 确保跨页表格的标题宽度与页面一致
\AtBeginEnvironment{longtable}{\setlength{\LTcapwidth}{\textwidth}}
\AtBeginEnvironment{xltabular}{\setlength{\LTcapwidth}{\textwidth}}

% [7.3] 编号格式定义 (章-序号)
% 注意：\counterwithin 已经处理了计数器重置逻辑
% 这里只需要定义显示的格式即可
\renewcommand\thesubfigure{(\alph{subfigure})}
\renewcommand{\theequation}{\thesection-\arabic{equation}}
\renewcommand{\thefigure}{\thesection-\arabic{figure}}
\renewcommand{\thetable}{\thesection-\arabic{table}}

% [7.4] 引用格式宏 (自动添加前缀)
\labelformat{figure}{图~#1}
\labelformat{table}{表~#1}
\labelformat{equation}{式~(#1)}

% [7.5] 符号重定义
\renewcommand{\leq}{\leqslant}
\renewcommand{\geq}{\geqslant}

% [7.6] 上标引用指令 (upcite)
% 功能：生成右上角标注，如 "文献[1]"，支持点击跳转
% 原理：利用 textsuperscript 将 natbib 的 cite 输出抬升
\newcommand{\upcite}[1]{%
	\textsuperscript{\cite{#1}}%
}




% ---------------------------------------------------------
% 8. PDF 属性设置
% ---------------------------------------------------------
\hypersetup{
	hidelinks,          % 隐藏链接边框和颜色
	colorlinks=false,   % 不使用彩色链接
	bookmarksnumbered=true,
	bookmarksopen=true,
	pdfstartview=FitH
}

% ---------------------------------------------------------
% 9. 特殊功能环境 (摘要、参考文献、附录、任务书、封面)
% ---------------------------------------------------------

% [9.1] 摘要环境
\newenvironment{cnabstract}[1]{
	\def\@keyword{#1}
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{摘要} % 加入目录
	\begin{center} \heiti\zihao{3} \@title \end{center}
	\vspace{1ex}
	\begin{center} \heiti\zihao{4} 摘　要 \end{center}
	\par
}{
	\par\vspace{2ex}
	\noindent{\heiti\zihao{-4} 关键词：}\@keyword
	\newpage
}

% [9.2] 参考文献自动化
\newcommand{\MyBibliography}[1]{
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{参考文献}
	% 临时禁用 section 命令，防止 bibliography 自动产生大标题
	\renewcommand{\section}[2]{}%
	\bibliographystyle{plain} 
	\bibliography{#1}
}

% 手动参考文献环境重定义
\renewenvironment{thebibliography}[1]{
	\section*{参考文献}
	\addcontentsline{toc}{section}{参考文献}
	\list{\@biblabel{\@arabic\c@enumiv}}%
	{\settowidth\labelwidth{\@biblabel{#1}}%
		\leftmargin\labelwidth
		\advance\leftmargin\labelsep
		\usecounter{enumiv}%
		\let\p@enumiv\@empty
		\renewcommand\theenumiv{\@arabic\c@enumiv}}%
	\sloppy
	\clubpenalty4000
	\widowpenalty4000
	\sfcode`\.\@m}
{\def\@noitemerr
	{\@latex@warning{Empty `thebibliography' environment}}%
	\endlist}

% [9.3] 附录环境 (修复版)
\newenvironment{appendixblock}{
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{附录} % 在目录添加"附录"条目
	
	\setcounter{section}{0}     % 重置章节计数
	\setcounter{subsection}{0}
	
	% 附录编号改为 A, B, C...
	\renewcommand{\thesection}{\Alph{section}} 
	
	% 修改 section 在正文中的显示格式 (如: 附录A)
	\ctexset{
		section = {
			name = {附录,},
			number = \thesection,
			format = \centering\zihao{4}\heiti\bfseries
		}
	}
	
	% 修改 section 在目录中的显示格式
	\titlecontents{section}[0pt]
	{\addvspace{6pt}\bfseries\heiti\zihao{4}}
	{附录\thecontentslabel\quad} 
	{}
	{\titlerule*[0.5pc]{.}\contentspage}
}{}




% [9.5] 封面生成模块
% 辅助命令: 智能填空下划线
% 逻辑: 内容短时居中加下划线，内容长时自动换行每行加下划线
% ---------------------------------------------------------
% 8. 封面与任务书模块
% ---------------------------------------------------------

% 辅助：智能下划线
\newcommand{\CoverInfo}[1]{%
	\begin{minipage}[t]{10.5cm} 
		\centering 
		\renewcommand{\arraystretch}{1.2}
		\sbox0{#1}%
		\ifdim\wd0<10.4cm 
		\uline{\makebox[10.4cm][c]{#1}}%
		\else
		\parbox[t]{10.5cm}{\centering\uline{#1}}%
		\fi
	\end{minipage}
}

% [任务书生成]
% ---------------------------------------------------------
% [支持跨页版] 任务书生成模块 (基于 xltabular)
% 解决：内容过长无法自动换页、底部内容丢失问题
% ---------------------------------------------------------
\newcommand{\maketaskbook}{
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{任务书}
	\thispagestyle{empty} % 首页无页码
	
	% 1. 标题区域
	\begin{center}
		\vspace*{-1.5cm} 
		\zihao{2}\bfseries\heiti 任务书
	\end{center}
	\vspace{0.3cm} 
	
	% 2. 表格设置
	\zihao{-4}\songti
	\renewcommand{\arraystretch}{1.35} 
	
	% 3. 开始 xltabular 环境 (用法类似 tabularx，但支持跨页)
	% 列定义：
	% 1. 标签列 1.6cm
	% 2. 组长列 3.0cm (固定宽)
	% 3. 标签列 1.6cm
	% 4. 队员列 X (自适应剩余)
	\begin{xltabular}{\textwidth}{|p{1.6cm}<{\centering}|p{3.0cm}<{\centering}|p{1.6cm}<{\centering}|X|}
		
		% --- A. 首页表头定义 ---
		\hline
		\bfseries 组长 & \@author & 
		\bfseries 队员 & \raggedright\arraybackslash \@team \\
		\hline
		\bfseries 设计题目 & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm\relax}|}{%
			\centering \vspace{0.2em} \@title \vspace{0.2em}%
		} \\
		\hline
		\endfirsthead % 首页表头结束
		
		% --- B. 续页表头定义 (如果跨页，第二页顶部显示这个) ---
		\multicolumn{4}{r}{\zihao{5}\kaishu （续表）} \\ 
		\hline
		\endhead % 续页表头结束
		
		% --- C. 页脚定义 ---
		\hline
		\endfoot % 每页底部的线
		
		% --- D. 最后一页页脚 ---
		\hline
		\endlastfoot % 最后一页底部的线
		
		% --- E. 表格正文内容 ---
		
		% [调查目标]
		\bfseries 调查目标 & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm\relax}|}{%
			\vspace{0.3em}\taskTargetText\vspace{0.3em}
		} \\
		\hline
		
		% [调查对象]
		\bfseries 调查对象 & \multicolumn{3}{l|}{黑龙江科技大学在读本科生，有效样本 205 份。} \\
		\hline
		
		% [方案设计] (这里内容通常最长，会自动跨页)
		\bfseries 方案设计 & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm\relax}|}{%
			\vspace{0.3em}\taskContentText\vspace{0.3em}
		} \\
		\hline
		
		% [预期结果]
		\bfseries 预期结果 & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm\relax}|}{%
			\vspace{0.3em}\taskExpectedText\vspace{0.3em}
		} \\
		\hline
		
		% [计划进度]
		\bfseries 计划进度 & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm\relax}|}{%
			\vspace{0.3em}\taskScheduleText\vspace{0.3em}
		} \\
		
	\end{xltabular}
	\newpage
}

% [封面生成]
\newcommand{\makecover}{
	\begin{titlepage}
		\begin{tikzpicture}[remember picture, overlay]
			\node[anchor=north east, xshift=-2cm, yshift=-2cm] at (current page.north east) {
				\setkeys{Gin}{draft=false} 
				\IfFileExists{assets/logo.png}{\includegraphics[width=0.25\textwidth]{assets/logo.png}}{
					\IfFileExists{figure/assets/logo.png}{\includegraphics[width=0.25\textwidth]{figure/assets/logo.png}}{}}
			};
		\end{tikzpicture}
		
		\vspace*{1cm}
		\centering
		
		\begin{flushright}
			\zihao{4}\bfseries\@reportID
		\end{flushright}
		\vspace{1.5cm} % 调整间距
		
		{\zihao{1}\bfseries\heiti 黑龙江科技大学\par}
		\vspace{1.5cm}
		{\fontsize{36pt}{36pt}\bfseries\songti 社会调查报告 \par}
		\vspace{2.5cm}
		
		\zihao{3}\songti
		\renewcommand{\arraystretch}{2.0} 
		
		\begin{tabular}{r l} 
			\textbf{题\quad 目} & \CoverInfo{\@title} \\ 
			% [关键修改] 这里同时显示组长和队员
			\textbf{姓\quad 名} & \CoverInfo{\@author、\@team} \\ 
			\textbf{院 (系)}    & \CoverInfo{\@dept} \\
			\textbf{专业、年级} & \CoverInfo{\@major} \\
			\textbf{指导教师}   & \CoverInfo{\@advisor} \\
		\end{tabular}
		
		\vfill
		{\zihao{3}\songti \today}
		\vspace{2cm}
	\end{titlepage}
}

% ---------------------------------------------------------
% 10. 高级图文混排与多图环境 (最终修复版)
% ---------------------------------------------------------
\RequirePackage{xparse}    % 引入高级参数处理宏包

% [10.1] 图文混排环境 (textfigure)
% 语法: \begin{textfigure}[位置]{图片路径}{标题}[宽度比例]
	\newsavebox{\tf@textbox}
	\newlength{\tf@imagew}
	\newlength{\tf@textw}
	
	% 💡 定义用于比较的常量
	\def\tf@left{left}
	
	\NewDocumentEnvironment{textfigure}{O{right} m m O{0.4}}{%
		\def\tf@pos{#1}%
		\def\tf@path{#2}%
		\def\tf@cap{#3}%
		\setlength{\tf@imagew}{#4\textwidth}%
		
		% 计算文字宽度 = 总宽度 - 图片宽度 - 间距
		\setlength{\tf@textw}{\textwidth}%
		\addtolength{\tf@textw}{-\tf@imagew}%
		\addtolength{\tf@textw}{-1.5em}%
		
		% 开始捕获文字
		\begin{lrbox}{\tf@textbox}%
			\begin{minipage}{\tf@textw}%
				\setlength{\parindent}{2em}%
				\linespread{1.5}\selectfont%
			}{%
			\end{minipage}%
		\end{lrbox}%
		
		\par\vspace{1em}\noindent
		% 💡 使用 \ifx 比较宏展开后的内容
		\ifx\tf@pos\tf@left
		% === 左图右文 ===
		\begin{minipage}[c]{\tf@imagew}
			\centering
			\includegraphics[width=\linewidth]{\tf@path}
			% 临时禁用 hypcap 解决警告，使用 captionof 生成标题
			\captionsetup{hypcap=false}%
			\captionof{figure}{\tf@cap}
		\end{minipage}%
		\hfill
		\usebox{\tf@textbox}
		\else
		% === 右图左文 ===
		\usebox{\tf@textbox}%
		\hfill
		\begin{minipage}[c]{\tf@imagew}
			\centering
			\includegraphics[width=\linewidth]{\tf@path}
			\captionsetup{hypcap=false}%
			\captionof{figure}{\tf@cap}
		\end{minipage}
		\fi
		\par\vspace{1em}
	}
	
	% [10.2] 强力并行图片环境 (parallelfigures)
	% 修复重点：改用 subfigure 环境，解决 Package caption Error
	\newcommand{\pf@maincap}{}
	
	\NewDocumentEnvironment{parallelfigures}{m}{%
		\renewcommand{\pf@maincap}{#1}%
		\begin{figure}[H] % 强制位置
			\centering
			% 定义内部快捷命令 \addfig[宽度]{路径}{标题}
			\newcommand{\addfig}[3][0.48]{%
				% 使用 subfigure 环境 (由 subcaption 宏包提供)
				% [b] 表示底部对齐，避免长短不一时的错位
				\begin{subfigure}[b]{##1\textwidth} 
					\centering
					\includegraphics[width=\linewidth]{##2}
					\caption{##3} % 这里的 caption 现在是安全的
				\end{subfigure}%
				\hspace{\fill}% 自动间隔
			}%
		}{%
			\caption{\pf@maincap}%
		\end{figure}%
	}

	% [10.3] 简洁多图行环境 (figurerow)
	% 用法: \begin{figurerow}{总标题}{列数}
	%           \figitem{路径}{子标题}
	%           \figitem{路径}{子标题}
	%       \end{figurerow}
	\newcommand{\fr@maincap}{}
	\newcommand{\fr@cols}{2}
	
	\NewDocumentEnvironment{figurerow}{m O{2}}{%
		\renewcommand{\fr@maincap}{#1}%
		\renewcommand{\fr@cols}{#2}%
		\begin{figure}[H]
			\centering
			% 根据列数计算宽度
			\newlength{\fr@width}%
			\setlength{\fr@width}{\dimexpr(\textwidth-1em*#2)/#2\relax}%
			% 定义内部命令
			\newcommand{\figitem}[2]{%
				\begin{subfigure}[b]{\fr@width}
					\centering
					\includegraphics[width=\linewidth]{##1}
					\caption{##2}
				\end{subfigure}\hfill
			}%
		}{%
			\caption{\fr@maincap}
		\end{figure}
	}

	% [10.4] 网格图片环境 (figuregrid) - 支持2x2, 2x3等网格布局
	% 用法: \begin{figuregrid}{总标题}
	%           \gridrow{
	%               \gridfig{路径}{子标题}
	%               \gridfig{路径}{子标题}
	%           }
	%       \end{figuregrid}
	\newcommand{\fg@maincap}{}
	
	\NewDocumentEnvironment{figuregrid}{m}{%
		\renewcommand{\fg@maincap}{#1}%
		\begin{figure}[H]
			\centering
			% 定义网格行命令
			\newcommand{\gridrow}[1]{%
				##1\par\vspace{0.5em}%
			}%
			% 定义网格单元命令 [宽度]{路径}{标题}
			\newcommand{\gridfig}[3][0.48]{%
				\begin{subfigure}[b]{##1\textwidth}
					\centering
					\includegraphics[width=\linewidth]{##2}
					\caption{##3}
				\end{subfigure}\hfill
			}%
		}{%
			\caption{\fg@maincap}
		\end{figure}
	}



% 11. 专业代码环境配置 (最终稳定版：移除冲突配置)
% ---------------------------------------------------------
\RequirePackage{listings}
\RequirePackage{xcolor}
% 引入 breakable 支持跨页, skins 支持阴影
\RequirePackage[most,listings,xparse,breakable]{tcolorbox}

% [11.1] 定义全局共享计数器
\newcounter{hustcode}[section] 
\renewcommand{\thehustcode}{\thesection-\arabic{hustcode}}

% [11.2] 视觉配色 (仿 VSCode Light)
\definecolor{hust@codeback}{RGB}{250,250,250}   % 亮灰背景
\definecolor{hust@codeframe}{RGB}{220,220,220}  % 边框颜色
\definecolor{hust@keyword}{RGB}{0,92,197}       % 关键字蓝
\definecolor{hust@comment}{RGB}{80,161,79}      % 注释绿
\definecolor{hust@string}{RGB}{227,17,108}      % 字符串红
\definecolor{hust@number}{RGB}{160,160,160}     % 行号灰

% [11.3] 核心 listings 样式配置
\lstdefinestyle{huststyle}{
	basicstyle=\small\ttfamily, % 字号与等宽字体
	keywordstyle=\bfseries\color{hust@keyword},
	commentstyle=\itshape\color{hust@comment},
	stringstyle=\color{hust@string},
	numberstyle=\tiny\color{hust@number},
	numbers=left,      % 显示行号
	numbersep=10pt,    % 行号与代码间距
	stepnumber=1,
	breaklines=true,   % 自动换行
	breakatwhitespace=false,
	showstringspaces=false,
	showtabs=false,    % 不显示 Tab 标记
	captionpos=b,
	frame=none,
	% [关键配置 1] 符号与兼容性
	extendedchars=false, % 解决中文注释报错
	escapechar=,         % [核心修复] 清空转义符！防止 @ 符号破坏代码解析
	upquote=true,        % 使用直引号
	% [关键配置 2] 缩进与原样输出
	tabsize=4,           % Tab = 4 空格 (listings 会自动处理，无需 literate)
	keepspaces=true,     % 严格保留代码缩进
	mathescape=false,    % 关闭数学模式，确保 $ 原样输出
	texcl=false,         % 关闭 TeX 注释，确保 % 原样输出
	columns=flexible     % 弹性列宽，防止复制乱码
	% [关键操作] 已删除 literate 选项，解决 Improper alphabetic constant 报错
}

% [11.4] 通用 tcolorbox 外观定义 (Mac 风格 + 标准阴影)
\tcbset{
	hustcodestyle/.style={
		enhanced,
		breakable,         % 允许代码跨页
		colback=hust@codeback,
		colframe=hust@codeframe,
		listing only,
		% 标题样式
		title={\textbf{代码 \thehustcode：}#1},
		coltitle=black,
		fonttitle=\bfseries\heiti\small,
		attach boxed title to top center={yshift=-3mm},
		boxed title style={
			colback=white, 
			colframe=hust@codeframe, 
			boxrule=0.5pt,
			arc=3pt,
			drop shadow % 使用标准阴影
		},
		% 整体盒子样式
		sharp corners, 
		rounded corners=southeast, 
		arc=5pt,
		top=12pt, bottom=2pt, left=6pt, right=6pt, 
		boxrule=0.8pt,
		drop shadow, 
		% [装饰] Mac 风格三色点
		overlay unbroken and first={
			\draw[fill=red!70!white, draw=none] ([xshift=6mm,yshift=-1.5mm]frame.north west) circle (2.5pt);
			\draw[fill=yellow!70!white, draw=none] ([xshift=11mm,yshift=-1.5mm]frame.north west) circle (2.5pt);
			\draw[fill=green!70!white, draw=none] ([xshift=16mm,yshift=-1.5mm]frame.north west) circle (2.5pt);
		}
	}
}

% [11.5] 环境: codeblock (直接在 tex 中写代码)
\newtcblisting{codeblock}[2][c]{
	hustcodestyle={#2},
	listing engine=listings,
	listing options={style=huststyle, language=#1},
	code={\refstepcounter{hustcode}} 
}

% [11.6] 命令: \filecode (从外部文件导入)
\NewDocumentCommand{\filecode}{O{c} m m}{%
	\refstepcounter{hustcode}% 
	\tcbinputlisting{
		hustcodestyle={#2},
		listing engine=listings,
		listing file={#3},
		listing options={style=huststyle, language=#1}
	}%
}


% ---------------------------------------------------------
% 12. 英文摘要环境 (毕设必选)
% ---------------------------------------------------------
\newenvironment{enabstract}[1]{
	\def\@enkeyword{#1}
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{Abstract} % 加入目录
%	\begin{center} \bfseries\zihao{3} \@title \end{center}
	\vspace{1ex}
	\begin{center} \bfseries\zihao{4} Abstract \end{center}
	\par
	\linespread{1.5}\selectfont % 英文行距调整
	\zihao{-4} % 小四号字
}{
	\par\vspace{2ex}
	\noindent\textbf{Keywords: } \@enkeyword
	\newpage
}

% ---------------------------------------------------------
% 13. 伪代码/算法环境 (汉化配置)
% ---------------------------------------------------------
\RequirePackage{algorithm}
\RequirePackage{algorithmicx}
\RequirePackage{algpseudocode}

% [13.1] 汉化与配置
\floatname{algorithm}{算法} % 标题由 Algorithm 1 变为 算法 1
\renewcommand{\algorithmicrequire}{\textbf{输入：}}
\renewcommand{\algorithmicensure}{\textbf{输出：}}

% [13.2] 美化设置 (让它长得像教材里的样子)
% 如果需要给算法加框，可以使用 algorithm 自带的 float 属性，
% 或者像下面这样定义更紧凑的样式
\algrenewcommand\algorithmicindent{2.0em}% 缩进量

% ---------------------------------------------------------
% 14. 精美提示框与定理环境 (风格匹配代码块)
% ---------------------------------------------------------
% 基于 tcolorbox 定义，用于“定义”、“注意”、“结论”
\tcbset{
	commonbox/.style={
		enhanced,
		breakable,
		sharp corners,
		rounded corners=southeast,
		arc=4pt,
		boxrule=1pt,
		drop shadow,
		attach boxed title to top left={yshift=-2mm, xshift=5mm},
		boxed title style={boxrule=0pt, colframe=white, colback=white},
		fonttitle=\bfseries\heiti,
		top=12pt
	}
}

% [14.1] 提示/注意框 (蓝色系)
% 用法: \begin{notice}{标题} ... \end{notice}
\newtcolorbox{notice}[1]{
	commonbox,
	colback=Azure1,      % 背景淡蓝
	colframe=DodgerBlue3,% 边框深蓝
	coltitle=DodgerBlue3,
	title={【注意】#1}
}

% [14.2] 概念/定义框 (绿色系)
% 用法: \begin{definition}{术语名称} ... \end{definition}
\newtcolorbox{definition}[1]{
	commonbox,
	colback=Honeydew1,    % 背景淡绿
	colframe=ForestGreen, % 边框深绿
	coltitle=ForestGreen,
	title={【定义】#1}
}

% [14.3] 结论/重点框 (红色系)
% 用法: \begin{conclusion}{结论} ... \end{conclusion}
\newtcolorbox{conclusion}[1]{
	commonbox,
	colback=LavenderBlush1, % 背景淡红
	colframe=Crimson,       % 边框深红
	coltitle=Crimson,
	title={【结论】#1}
}

% ---------------------------------------------------------
% 15. 致谢环境
% ---------------------------------------------------------
\newenvironment{acknowledgement}{
	\clearpage
	\phantomsection
	\addcontentsline{toc}{section}{致谢}
	\section*{致谢}
	\zihao{-4}\songti\linespread{1.5}\selectfont
}{
	\par
}

% ---------------------------------------------------------
% 16. 列表环境优化 (专业出版级定制)
% ---------------------------------------------------------
\RequirePackage{enumitem}
\RequirePackage{tikz} 
\RequirePackage{amssymb} % 补充数学符号

% [16.0] 专业绘图微调 (Visual Assets)
% 1. 一级列表标号：实心方块 (基线微调，让它正对文字中间)
\newcommand{\hust@item@square}{%
	\tikz[baseline=-0.6ex] \node[fill=black, shape=rectangle, inner sep=0pt, minimum size=0.5em] {};%
}

% 2. 二级列表标号：深灰圆点 (视觉降噪)
\newcommand{\hust@item@circle}{%
	\tikz[baseline=-0.6ex] \node[fill=darkgray, shape=circle, inner sep=0pt, minimum size=0.35em] {};%
}

% 3. 三级列表标号：细长横线 (引导线)
\newcommand{\hust@item@dash}{%
	\tikz[baseline=-0.6ex] \draw[line width=0.8pt] (0,0) -- (0.5em,0);%
}

% 4. 序号绘制 (方块反白 / 圆圈数字)
\newcommand{\hust@circled}[1]{%
	\begin{tikzpicture}[baseline=(char.base)]
		\node[shape=circle, draw=black, inner sep=0.5pt, minimum size=1.2em, line width=0.6pt] (char) {\small\bfseries #1};
	\end{tikzpicture}%
}
\newcommand{\hust@squared}[1]{%
	\begin{tikzpicture}[baseline=(char.base)]
		\node[shape=rectangle, draw=black, fill=black, text=white, rounded corners=2pt, inner sep=1pt, minimum size=1.2em] (char) {\small\bfseries #1};
	\end{tikzpicture}%
}

% [16.1] 全局基础参数设置
\setlist{
	nosep, % 紧凑模式基础
	itemsep=3pt,  % 条目间微距 (增加呼吸感)
	parsep=0pt,   % 段内无间距
	topsep=4pt,   % 列表与正文间距
	partopsep=0pt
}

% [16.2] 无序列表深度定制 (Itemize)
% Level 1: 实心方块 -> 强调结构感
\setlist[itemize,1]{
	label=\protect\hust@item@square,
	leftmargin=2.0em, labelsep=0.6em
}
% Level 2: 深灰圆点 -> 强调子集关系，颜色变浅
\setlist[itemize,2]{
	label=\protect\hust@item@circle,
	leftmargin=1.8em, labelsep=0.6em
}
% Level 3: 短横线 -> 强调属性或参数
\setlist[itemize,3]{
	label=\protect\hust@item@dash,
	leftmargin=1.8em, labelsep=0.6em
}

% [16.3] 有序列表深度定制 (Enumerate)
% 默认样式优化：1. 字体对齐
\setlist[enumerate,1]{
	label=\arabic*.,
	leftmargin=2.0em, labelsep=0.5em
}
\setlist[enumerate,2]{
	label=(\arabic*),
	leftmargin=2.0em, labelsep=0.5em
}

% [16.4] 自定义样式：括号列表 (enumpar)
\newlist{enumpar}{enumerate}{1}
\setlist[enumpar]{
	label=(\arabic*),
	leftmargin=2.5em, labelsep=0.5em, itemsep=2pt, align=left
}

% [16.5] 自定义样式：半括号列表 (enumbra)
\newlist{enumbra}{enumerate}{1}
\setlist[enumbra]{
	label=\arabic*),
	leftmargin=2.5em, labelsep=0.5em, itemsep=2pt, align=left
}

% [16.6] 自定义样式：圆圈序号 (enumcircled) -> ①
\newlist{enumcircled}{enumerate}{1}
\setlist[enumcircled]{
	label=\protect\hust@circled{\arabic*},
	leftmargin=2.8em, labelsep=0.6em, itemsep=3pt
}

% [16.7] 自定义样式：黑块序号 (enumsquared) -> 1️⃣
\newlist{enumsquared}{enumerate}{1}
\setlist[enumsquared]{
	label=\protect\hust@squared{\arabic*},
	leftmargin=2.8em, labelsep=0.6em, itemsep=3pt
}

% ---------------------------------------------------------
% 17. 锦上添花的功能 (目录树、跨页批注、元数据)
% ---------------------------------------------------------

% [17.1] 项目目录树绘制
\RequirePackage{dirtree}
\renewcommand{\DTstyle}{\ttfamily\small} 

% [17.2] 待办事项与批注 (基于 tcolorbox 重构，支持跨页)
% 说明：原版 todonotes 不支持内容跨页，这里改用 breakable 盒子
\tcbset{
	hust@todostyle/.style={
		enhanced,
		breakable,       % [核心] 允许跨页
		width=\textwidth,% 宽度占满行
		sharp corners,
		rounded corners=southeast,
		arc=3pt,
		boxrule=1pt,
		left=4pt, right=4pt, top=2pt, bottom=2pt,
		before skip=8pt, after skip=8pt, % 与正文的间距
		fonttitle=\bfseries\small,
		attach boxed title to top left={yshift=-2mm, xshift=3mm},
		boxed title style={boxrule=0pt, colframe=white}
	}
}

% 定义 \todo{内容} - 橙色，用于普通待办
\newcommand{\todo}[1]{%
	\begin{tcolorbox}[
		hust@todostyle, 
		colback=orange!5, 
		colframe=orange!80!black, 
		coltitle=orange!80!black,
		boxed title style={colback=orange!10},
		title={TODO (待办)}
		]
		#1
	\end{tcolorbox}%
}

% 定义 \fixme{内容} - 红色，用于亟需修改的地方
\newcommand{\fixme}[1]{%
	\begin{tcolorbox}[
		hust@todostyle, 
		colback=red!5, 
		colframe=red!75!black, 
		coltitle=red!75!black,
		boxed title style={colback=red!10},
		title={FIXME (需修正)}
		]
		#1
	\end{tcolorbox}%
}

% 定义 \note{内容} - 蓝色，用于补充说明或备忘
\newcommand{\note}[1]{%
	\begin{tcolorbox}[
		hust@todostyle, 
		colback=blue!5, 
		colframe=blue!65!black, 
		coltitle=blue!65!black, 
		boxed title style={colback=blue!10},
		title={NOTE (备注)}
		]
		#1
	\end{tcolorbox}%
}

% [17.3] 智能 PDF 元数据注入
\AtBeginDocument{
	\hypersetup{
		pdftitle={\@title},
		pdfauthor={\@author},
		pdfsubject={黑龙江科技大学实习报告/毕业设计},
		pdfcreator={HUST Report LaTeX Class}
	}
}

% =========================================================
% 18. 高级批注与审阅系统 (Review System - TikZ Absolute)
% =========================================================
% 功能：支持侧边批注、行间（上方/下方）批注
% 修复：解决了 width 属性报错问题
% =========================================================

% --- 1. 依赖库加载 ---
\RequirePackage{xparse}          % 用于 \NewDocumentCommand
\RequirePackage[most]{tcolorbox} % 用于 \tcbox (圆角框等)
\RequirePackage{tikz}            % 绘图引擎
\RequirePackage{tikzpagenodes}   % 获取页面绝对位置
\RequirePackage[normalem]{ulem}  % 下划线与波浪线支持

% --- 2. 参数定义 ---
\pgfkeys{
	/hustreview/.is family, /hustreview,
	style/.store in  = \hust@review@style,
	color/.store in  = \hust@review@color,
	side/.store in   = \hust@review@side,   % 支持 left, right, below, above
	offset/.store in = \hust@review@offset, % 垂直偏移量
	style/.default   = underline,
	color/.default   = red,
	side/.default    = right,
	offset/.default  = 0pt
}

% --- 3. 侧边批注绘制宏 (TikZ Overlay - 侧边模式) ---
\newcommand{\hust@drawsidenote}[4]{%
	% #1: 颜色, #2: 内容, #3: 方向(left/right), #4: 垂直偏移
	\begin{tikzpicture}[remember picture, overlay]
		\ifdefstring{#3}{left}{%
			% === 左侧绝对定位 ===
			% 关键修复：使用 text width 替代 width，解决报错
			\node[anchor=north, align=right, text width=2.0cm] 
			at ([xshift=1.5cm, yshift=#4]current page.west |- 0,0) {%
				\begingroup
				\color{#1}%
				\zihao{6}\songti\linespread{1.1}\selectfont
				\textbf{批注} $\rightarrow$\\
				#2
				\endgroup
			};
		}{%
			% === 右侧绝对定位 ===
			\node[anchor=north, align=left, text width=2.0cm] 
			at ([xshift=-1.5cm, yshift=#4]current page.east |- 0,0) {%
				\begingroup
				\color{#1}%
				\zihao{6}\songti\linespread{1.1}\selectfont
				$\leftarrow$ \textbf{批注}\\
				#2
				\endgroup
			};
		}%
	\end{tikzpicture}%
}

% --- 4. 行间批注绘制宏 (TikZ Overlay - 行间模式) ---
\newcommand{\hust@drawinlinenote}[4]{%
	% #1: 颜色, #2: 内容, #3: 方向(below/above), #4: 垂直偏移
	\begin{tikzpicture}[remember picture, overlay]
		\ifdefstring{#3}{above}{%
			% === 上方行间插入 ===
			% anchor=south west: 从基线左上角向上生长
			\node[anchor=south west, inner sep=0pt, align=left, text width=8cm, yshift=0.8em+#4] 
			at (0,0) {%
				\begingroup
				\color{#1}\zihao{7}\songti #2 % 使用7号字(小字)
				\endgroup
			};
		}{%
			% === 下方行间插入 (默认 below) ===
			% anchor=north west: 从基线左下角向下生长
			\node[anchor=north west, inner sep=0pt, align=left, text width=8cm, yshift=-0.2em+#4] 
			at (0,0) {%
				\begingroup
				\color{#1}\zihao{7}\songti #2 % 使用7号字(小字)
				\endgroup
			};
		}%
	\end{tikzpicture}%
}

% --- 5. 核心命令 \review ---
\NewDocumentCommand{\review}{ O{} m +m }{%
	% 1. 解析参数
	\pgfkeys{/hustreview, style=underline, color=red, side=right, offset=0pt, #1}%
	%
	% 2. 正文标记渲染
	\begingroup
	\color{\hust@review@color}%
	\ifdefstring{\hust@review@style}{wave}{%
		\uwave{#2}%
	}{%
		\ifdefstring{\hust@review@style}{underline}{%
			\uline{#2}%
		}{%
			\ifdefstring{\hust@review@style}{strike}{%
				\sout{#2}%
			}{%
				\ifdefstring{\hust@review@style}{circle}{%
					\tcbox[enhanced, on line, arc=3pt, outer arc=3pt,
					colback=white, colframe=\hust@review@color,
					boxrule=0.8pt, left=2pt, right=2pt, top=0pt, bottom=0pt,
					boxsep=1pt, nobeforeafter, tcbox raise base]{#2}%
				}{%
					\ifdefstring{\hust@review@style}{highlight}{%
						\tcbox[on line, arc=0pt, outer arc=0pt,
						colback=\hust@review@color!20!white,
						colframe=\hust@review@color!20!white,
						boxrule=0pt, left=1pt, right=1pt, top=0pt, bottom=0pt,
						boxsep=0pt, nobeforeafter, tcbox raise base]{#2}%
					}{%
						\uline{#2}%
	}}}}}%
	\endgroup
	%
	% 3. 批注渲染 (智能判断侧边还是行间)
	\if\relax\detokenize{#3}\relax
	\else
	% 判断 side 参数是否为 below 或 above
	\ifdefstring{\hust@review@side}{below}{%
		\hust@drawinlinenote{\hust@review@color}{#3}{below}{\hust@review@offset}%
	}{%
		\ifdefstring{\hust@review@side}{above}{%
			\hust@drawinlinenote{\hust@review@color}{#3}{above}{\hust@review@offset}%
		}{%
			% 默认为侧边 (left/right)
			\hust@drawsidenote{\hust@review@color}{#3}{\hust@review@side}{\hust@review@offset}%
		}%
	}%
	\fi
}

% --- 6. 别名定义 ---
\newcommand{\标注}{\review}
\newcommand{\selfreview}{\review}

% =========================================================
% 19. 教程文档展示环境 (Tutorial Documentation Environments)
% =========================================================
% 功能：用于编写 LaTeX 类文件/宏包的使用文档
% 提供代码+效果并排展示（左右、上下布局）
% =========================================================

% --- 19.1 依赖确认 (tcolorbox + listings 已在前文加载) ---

% --- 19.2 配色方案 ---
\definecolor{hust@demo@codebg}{RGB}{248,248,248}     % 代码区背景
\definecolor{hust@demo@resultbg}{RGB}{255,255,245}   % 效果区背景
\definecolor{hust@demo@frame}{RGB}{200,200,200}      % 边框颜色
\definecolor{hust@api@bg}{RGB}{240,248,255}          % API 卡片背景
\definecolor{hust@api@frame}{RGB}{70,130,180}        % API 卡片边框

% --- 19.3 代码展示基础样式 (用于文档) ---
\lstdefinestyle{demostyle}{
    basicstyle=\small\ttfamily,
    keywordstyle=\bfseries\color{hust@keyword},
    commentstyle=\itshape\color{hust@comment},
    stringstyle=\color{hust@string},
    backgroundcolor=\color{hust@demo@codebg},
    frame=none,
    breaklines=true,
    showstringspaces=false,
    tabsize=2,
    columns=flexible,
    keepspaces=true,
    extendedchars=false,
    texcl=false,
    mathescape=false
}

% --- 19.4 democode 环境：左右双栏展示 ---
% 用法：\begin{democode}{标题} LaTeX代码 \end{democode}
% 左侧显示源代码，右侧显示编译效果
\newtcblisting{democode}[1]{
    enhanced,
    breakable,
    title={#1},
    fonttitle=\bfseries\heiti,
    coltitle=black,
    colbacktitle=gray!15,
    colframe=hust@demo@frame,
    boxrule=0.8pt,
    arc=3pt,
    listing engine=listings,
    listing options={style=demostyle},
    sidebyside,
    sidebyside align=top,
    lefthand ratio=0.5,
    righthand width=0.46\linewidth,
    colback=hust@demo@codebg,
    segmentation style={solid, hust@demo@frame},
    % 右侧效果区样式
    bicolor,
    colbacklower=hust@demo@resultbg,
    % 间距
    left=3pt, right=3pt, top=2pt, bottom=2pt,
    middle=3pt
}

% --- 19.5 demovert 环境：上下布局展示 ---
% 用法：\begin{demovert}{标题} LaTeX代码 \end{demovert}
% 上方显示源代码，下方显示编译效果
\newtcblisting{demovert}[1]{
    enhanced,
    breakable,
    title={#1},
    fonttitle=\bfseries\heiti,
    coltitle=black,
    colbacktitle=gray!15,
    colframe=hust@demo@frame,
    boxrule=0.8pt,
    arc=3pt,
    listing engine=listings,
    listing options={style=demostyle},
    listing and text,
    colback=hust@demo@codebg,
    segmentation style={solid, hust@demo@frame},
    % 下方效果区样式
    bicolor,
    colbacklower=hust@demo@resultbg,
    % 间距
    left=5pt, right=5pt, top=3pt, bottom=3pt,
    middle=3pt
}

% --- 19.6 codeonly 环境：仅展示代码 ---
% 用法：\begin{codeonly}{标题} LaTeX代码 \end{codeonly}
\newtcblisting{codeonly}[1]{
    enhanced,
    breakable,
    title={#1},
    fonttitle=\bfseries\heiti,
    coltitle=black,
    colbacktitle=gray!15,
    colframe=hust@demo@frame,
    colback=hust@demo@codebg,
    boxrule=0.8pt,
    arc=3pt,
    listing engine=listings,
    listing options={style=demostyle},
    listing only,
    left=5pt, right=5pt, top=3pt, bottom=3pt
}

% --- 19.7 apibox 命令：API 参考卡片 ---
% 用法：\apibox{命令名}{参数说明}{功能描述}
\newcommand{\apibox}[3]{%
    \begin{tcolorbox}[
        enhanced,
        colback=hust@api@bg,
        colframe=hust@api@frame,
        boxrule=1pt,
        arc=4pt,
        left=8pt, right=8pt, top=6pt, bottom=6pt,
        fonttitle=\bfseries\ttfamily,
        title={\textbackslash #1},
        coltitle=white,
        colbacktitle=hust@api@frame,
        attach boxed title to top left={xshift=5mm, yshift=-3mm},
        boxed title style={arc=2pt, boxrule=0pt}
    ]
    \textbf{参数：} \texttt{#2} \\[3pt]
    \textbf{说明：} #3
    \end{tcolorbox}
}

% --- 19.8 optionlist 环境：选项列表 ---
% 使用简单的 tabular 实现，完全避免 xeCJK 兼容性问题
\newenvironment{optionlist}{%
    \par\vspace{0.5em}%
    \noindent%
}{%
    \par\vspace{0.5em}%
}

% \option 命令：选项条目
\newcommand{\option}[2]{%
    \noindent\hspace{1em}%
    \texttt{\bfseries\color{hust@api@frame}#1}%
    \hspace{0.5em}---\hspace{0.5em}#2%
    \par\vspace{0.3em}%
}

% --- 19.9 inlinecode 命令：行内代码高亮 ---
\newcommand{\cmd}[1]{\texttt{\textbackslash #1}}
\newcommand{\env}[1]{\texttt{#1}}
\newcommand{\opt}[1]{\texttt{[#1]}}

\makeatother
% =========================================================
% End of Class File
% =========================================================
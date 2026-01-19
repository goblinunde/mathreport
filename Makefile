# =========================================================
# MindFlow LaTeX 项目 Makefile
# 用法: make [target]
# 版本: 2.0 (2026-01-06)
# =========================================================

# 配置
LATEX := xelatex
BIBTEX := bibtex
MAKEINDEX := makeindex
LATEXFLAGS := -interaction=nonstopmode -file-line-error -halt-on-error

# 主文档（不带扩展名）
DOCS := mindflow_demo mathnotes mathbook mathreport

# 类文件依赖
CLS := mindflow.cls

# PDF 输出文件
PDFS := $(addsuffix .pdf,$(DOCS))

# 临时文件扩展名
TEMP_EXTS := aux log toc out bbl blg lot lof fls fdb_latexmk synctex.gz \
             nav snm vrb listing idx ilg ind glo gls glg run.xml bcf xdv pyg nlo nls

# 默认目标
.PHONY: all clean cleanall help demo notes book report watch quick parallel check

# ───────────────────────────────────────────────────────────
# 主要目标
# ───────────────────────────────────────────────────────────

# 串行编译所有文档
all: $(PDFS)
	@echo ""
	@echo "╔════════════════════════════════════════╗"
	@echo "║  ✅ 所有文档编译完成!                  ║"
	@echo "╚════════════════════════════════════════╝"

# 并行编译（利用多核 CPU）
parallel:
	@echo "🚀 并行编译所有文档 ($(shell nproc) 核心)..."
	@$(MAKE) -j$(shell nproc) $(PDFS)
	@echo "✅ 并行编译完成!"

# ───────────────────────────────────────────────────────────
# 快捷目标
# ───────────────────────────────────────────────────────────

demo: mindflow_demo.pdf
	@echo "✅ mindflow_demo.pdf 编译完成!"

notes: mathnotes.pdf
	@echo "✅ mathnotes.pdf 编译完成!"

book: mathbook.pdf
	@echo "✅ mathbook.pdf 编译完成!"

report: mathreport.pdf
	@echo "✅ mathreport.pdf 编译完成!"

# ───────────────────────────────────────────────────────────
# 编译规则
# ───────────────────────────────────────────────────────────

# 完整编译规则：PDF 依赖于 TEX 和 CLS
%.pdf: %.tex $(CLS)
	@echo "📝 编译 $< ..."
	@$(LATEX) $(LATEXFLAGS) $< > /dev/null 2>&1 || \
		(echo "❌ 第一次编译失败，显示错误:"; $(LATEX) $(LATEXFLAGS) $< | tail -30; exit 1)
	@# 处理术语表
	@if [ -f $*.nlo ] && [ -s $*.nlo ]; then \
		echo "  🔤 生成术语表..."; \
		$(MAKEINDEX) $*.nlo -s nomencl.ist -o $*.nls > /dev/null 2>&1 || true; \
	fi
	@# 处理参考文献
	@if grep -q '\\bibliography{' $< 2>/dev/null; then \
		echo "  📚 处理参考文献..."; \
		$(BIBTEX) $* > /dev/null 2>&1 || true; \
	fi
	@# 第二次编译
	@$(LATEX) $(LATEXFLAGS) $< > /dev/null 2>&1
	@# 第三次编译（确保交叉引用正确）
	@$(LATEX) $(LATEXFLAGS) $< > /dev/null 2>&1
	@echo "  📄 生成 $@"

# 快速编译（单次，用于预览）
quick:
	@for doc in $(DOCS); do \
		echo "⚡ 快速编译 $$doc.tex..."; \
		$(LATEX) $(LATEXFLAGS) $$doc.tex > /dev/null 2>&1 || \
			echo "  ⚠️  $$doc 编译有警告"; \
	done
	@echo "✅ 快速编译完成!"

# ───────────────────────────────────────────────────────────
# 清理目标
# ───────────────────────────────────────────────────────────

# 清理临时文件（保留 PDF）
clean:
	@echo "🧹 清理临时文件..."
	@for ext in $(TEMP_EXTS); do rm -f *.$$ext; done
	@rm -f *-blx.bib
	@echo "✅ 临时文件已清理 (PDF 已保留)"

# 完全清理（包括 PDF）
cleanall: clean
	@echo "🗑️  删除 PDF 文件..."
	@rm -f $(PDFS)
	@echo "✅ 所有生成文件已删除"

# ───────────────────────────────────────────────────────────
# 工具目标
# ───────────────────────────────────────────────────────────

# 检查环境
check:
	@echo "🔍 检查编译环境..."
	@echo -n "  XeLaTeX: "; which $(LATEX) || echo "未找到"
	@echo -n "  BibTeX:  "; which $(BIBTEX) || echo "未找到"
	@echo -n "  MakeIndex: "; which $(MAKEINDEX) || echo "未找到"
	@echo -n "  类文件:  "; test -f $(CLS) && echo "$(CLS) ✓" || echo "$(CLS) ✗"
	@echo -n "  图片目录: "; test -d figure && echo "figure/ ✓" || echo "figure/ ✗"
	@echo ""

# 查看 PDF
view: all
	@for doc in $(DOCS); do \
		if [ -f $$doc.pdf ]; then \
			echo "👁️  打开 $$doc.pdf..."; \
			xdg-open $$doc.pdf 2>/dev/null & \
		fi; \
	done

# 监视文件变化自动编译（需要 inotifywait）
watch:
	@echo "👀 监视文件变化... (Ctrl+C 退出)"
	@command -v inotifywait > /dev/null || (echo "请安装: sudo dnf install inotify-tools"; exit 1)
	@while true; do \
		inotifywait -qe modify *.tex *.cls 2>/dev/null; \
		echo ""; \
		echo "📝 检测到变化，重新编译..."; \
		$(MAKE) quick; \
		echo ""; \
	done

# 打包发布
dist: cleanall
	@echo "📦 创建发布包..."
	@mkdir -p dist
	@tar -czvf dist/mindflow-$(shell date +%Y%m%d).tar.gz \
		*.tex $(CLS) \
		figure/ fonts/ README.md Makefile build.sh \
		--exclude='*.pdf' --exclude='*.aux' --exclude='*.log' 2>/dev/null
	@echo "✅ 发布包: dist/mindflow-$(shell date +%Y%m%d).tar.gz"

# ───────────────────────────────────────────────────────────
# 帮助信息
# ───────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║             MindFlow LaTeX 项目构建系统 v2.0               ║"
	@echo "╠════════════════════════════════════════════════════════════╣"
	@echo "║  编译命令:                                                 ║"
	@echo "║    make all       - 串行编译所有文档                       ║"
	@echo "║    make parallel  - 并行编译（推荐，速度更快）             ║"
	@echo "║    make demo      - 编译演示文档 (mindflow_demo.pdf)       ║"
	@echo "║    make notes     - 编译笔记模版 (mathnotes.pdf)           ║"
	@echo "║    make book      - 编译书籍模版 (mathbook.pdf)            ║"
	@echo "║    make report    - 编译报告模版 (mathreport.pdf)          ║"
	@echo "║    make quick     - 快速编译（单次，用于预览）             ║"
	@echo "║                                                            ║"
	@echo "║  清理命令:                                                 ║"
	@echo "║    make clean     - 清理临时文件（保留 PDF）               ║"
	@echo "║    make cleanall  - 完全清理（包括 PDF）                   ║"
	@echo "║                                                            ║"
	@echo "║  工具命令:                                                 ║"
	@echo "║    make check     - 检查编译环境                           ║"
	@echo "║    make view      - 编译并打开所有 PDF                     ║"
	@echo "║    make watch     - 监视文件变化自动编译                   ║"
	@echo "║    make dist      - 打包发布                               ║"
	@echo "║    make help      - 显示此帮助信息                         ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""

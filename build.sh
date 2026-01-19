#!/bin/bash
# =========================================================
# MindFlow LaTeX 编译脚本
# 用法: ./build.sh [选项] [文档名...]
# 版本: 2.0 (2026-01-06)
# =========================================================

set -e

# ───────────────────────────────────────────────────────────
# 配置区
# ───────────────────────────────────────────────────────────

LATEX="xelatex"
BIBTEX="bibtex"
MAKEINDEX="makeindex"
LATEXFLAGS="-interaction=nonstopmode -file-line-error"

# 所有文档（不带扩展名）
ALL_DOCS=(mindflow_demo mathnotes mathbook mathreport)

# 类文件
CLS_FILE="mindflow.cls"

# 日志目录
LOG_DIR=".build_logs"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 统计变量
SUCCESS_COUNT=0
FAIL_COUNT=0
START_TIME=$(date +%s)

# ───────────────────────────────────────────────────────────
# 工具函数
# ───────────────────────────────────────────────────────────

log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }
log_step()    { echo -e "  ${CYAN}→ $1${NC}"; }

# 显示进度条
progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" $percent
}

# 显示耗时
show_duration() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local mins=$((duration / 60))
    local secs=$((duration % 60))
    echo -e "${CYAN}⏱️  总耗时: ${mins}分${secs}秒${NC}"
}

# ───────────────────────────────────────────────────────────
# 帮助信息
# ───────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'

╔═══════════════════════════════════════════════════════════════╗
║              MindFlow LaTeX 编译脚本 v2.0                     ║
╠═══════════════════════════════════════════════════════════════╣
║  用法: ./build.sh [选项] [文档名...]                          ║
║                                                               ║
║  编译选项:                                                    ║
║    -q, --quick      快速编译（单次，用于预览）                ║
║    -f, --full       完整编译（含参考文献，默认）              ║
║    -p, --parallel   并行编译（利用多核 CPU）                  ║
║                                                               ║
║  其他选项:                                                    ║
║    -c, --clean      清理临时文件                              ║
║    -C, --cleanall   完全清理（包括 PDF）                      ║
║    -v, --view       编译后打开 PDF                            ║
║    -w, --watch      监视文件变化自动编译                      ║
║    -l, --log        保存编译日志到 .build_logs/               ║
║    --check          检查编译环境                              ║
║    -h, --help       显示帮助                                  ║
║                                                               ║
║  文档名（可多选）:                                            ║
║    demo             mindflow_demo                             ║
║    notes            mathnotes                                 ║
║    book             mathbook                                  ║
║    report           mathreport                                ║
║    all              所有文档（默认）                          ║
║                                                               ║
║  示例:                                                        ║
║    ./build.sh                    # 完整编译所有               ║
║    ./build.sh -q notes book      # 快速编译 notes 和 book     ║
║    ./build.sh -p all             # 并行编译所有               ║
║    ./build.sh -v demo            # 编译 demo 并打开           ║
║    ./build.sh -l report          # 编译并保存日志             ║
╚═══════════════════════════════════════════════════════════════╝

EOF
}

# ───────────────────────────────────────────────────────────
# 清理函数
# ───────────────────────────────────────────────────────────

clean_temp() {
    log_info "清理临时文件..."
    rm -f *.aux *.log *.toc *.out *.bbl *.blg *.lot *.lof
    rm -f *.fls *.fdb_latexmk *.synctex.gz *.nav *.snm *.vrb
    rm -f *.listing *.idx *.ilg *.ind *.glo *.gls *.glg
    rm -f *.run.xml *.bcf *.xdv *.pyg *.nlo *.nls
    rm -f *-blx.bib
    log_success "临时文件已清理"
}

clean_all() {
    clean_temp
    log_info "删除 PDF 文件..."
    rm -f *.pdf
    rm -rf "$LOG_DIR"
    log_success "所有生成文件已删除"
}

# ───────────────────────────────────────────────────────────
# 环境检查
# ───────────────────────────────────────────────────────────

check_env() {
    echo ""
    log_info "检查编译环境..."
    echo ""
    
    local all_ok=true
    
    # 检查工具
    for tool in "$LATEX" "$BIBTEX" "$MAKEINDEX"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool: $(which $tool)"
        else
            echo -e "  ${RED}✗${NC} $tool: 未安装"
            all_ok=false
        fi
    done
    
    # 检查类文件
    if [ -f "$CLS_FILE" ]; then
        echo -e "  ${GREEN}✓${NC} 类文件: $CLS_FILE"
    else
        echo -e "  ${RED}✗${NC} 类文件: $CLS_FILE 不存在"
        all_ok=false
    fi
    
    # 检查图片目录
    if [ -d "figure" ]; then
        local img_count=$(find figure -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.pdf" \) 2>/dev/null | wc -l)
        echo -e "  ${GREEN}✓${NC} 图片目录: figure/ ($img_count 个文件)"
    else
        echo -e "  ${YELLOW}⚠${NC} 图片目录: figure/ 不存在"
    fi
    
    # 检查 inotifywait（用于 watch 模式）
    if command -v inotifywait &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} inotifywait: 可用 (watch 模式)"
    else
        echo -e "  ${YELLOW}⚠${NC} inotifywait: 未安装 (watch 模式不可用)"
        echo -e "      安装: sudo dnf install inotify-tools"
    fi
    
    echo ""
    if $all_ok; then
        log_success "环境检查通过"
    else
        log_error "环境检查失败，请安装缺失的组件"
        exit 1
    fi
}

# ───────────────────────────────────────────────────────────
# 编译函数
# ───────────────────────────────────────────────────────────

quick_compile() {
    local doc=$1
    local save_log=$2
    
    echo -e "${BLUE}⚡ 快速编译 ${BOLD}${doc}.tex${NC}${BLUE}...${NC}"
    
    local log_file="/dev/null"
    [ "$save_log" = true ] && log_file="$LOG_DIR/${doc}.log"
    
    if $LATEX $LATEXFLAGS "${doc}.tex" > "$log_file" 2>&1; then
        log_success "${doc}.pdf 编译成功"
        ((SUCCESS_COUNT++))
        return 0
    else
        log_error "${doc}.tex 编译失败"
        [ "$save_log" = true ] && echo "    查看日志: $log_file"
        # 显示最后几行错误
        $LATEX $LATEXFLAGS "${doc}.tex" 2>&1 | grep -A2 "^!" | head -10
        ((FAIL_COUNT++))
        return 1
    fi
}

full_compile() {
    local doc=$1
    local save_log=$2
    
    echo -e "${BLUE}📝 完整编译 ${BOLD}${doc}.tex${NC}${BLUE}...${NC}"
    
    local log_file="/dev/null"
    [ "$save_log" = true ] && log_file="$LOG_DIR/${doc}.log"
    
    # 第一次编译
    log_step "[1/3] 第一次编译..."
    if ! $LATEX $LATEXFLAGS "${doc}.tex" > "$log_file" 2>&1; then
        # 检查是否生成了 PDF（有警告但可能成功）
        if [ ! -f "${doc}.pdf" ]; then
            log_error "第一次编译失败"
            $LATEX $LATEXFLAGS "${doc}.tex" 2>&1 | grep -A2 "^!" | head -10
            ((FAIL_COUNT++))
            return 1
        fi
    fi
    
    # 处理术语表
    if [ -f "${doc}.nlo" ] && [ -s "${doc}.nlo" ]; then
        log_step "生成术语表..."
        $MAKEINDEX "${doc}.nlo" -s nomencl.ist -o "${doc}.nls" >> "$log_file" 2>&1 || true
    fi
    
    # 处理参考文献
    if grep -q '\\bibliography{' "${doc}.tex" 2>/dev/null; then
        log_step "处理参考文献..."
        $BIBTEX "$doc" >> "$log_file" 2>&1 || true
    fi
    
    # 第二次编译
    log_step "[2/3] 第二次编译..."
    $LATEX $LATEXFLAGS "${doc}.tex" >> "$log_file" 2>&1 || true
    
    # 第三次编译
    log_step "[3/3] 第三次编译..."
    $LATEX $LATEXFLAGS "${doc}.tex" >> "$log_file" 2>&1 || true
    
    if [ -f "${doc}.pdf" ]; then
        local size=$(du -h "${doc}.pdf" | cut -f1)
        log_success "${doc}.pdf 编译完成 ($size)"
        ((SUCCESS_COUNT++))
        return 0
    else
        log_error "${doc}.pdf 生成失败"
        ((FAIL_COUNT++))
        return 1
    fi
}

# 并行编译
parallel_compile() {
    local docs=("$@")
    local pids=()
    
    log_info "启动并行编译 (${#docs[@]} 个文档)..."
    
    for doc in "${docs[@]}"; do
        (
            # 子进程中编译
            $LATEX $LATEXFLAGS "${doc}.tex" > /dev/null 2>&1
            $LATEX $LATEXFLAGS "${doc}.tex" > /dev/null 2>&1
            $LATEX $LATEXFLAGS "${doc}.tex" > /dev/null 2>&1
        ) &
        pids+=($!)
        echo -e "  ${CYAN}启动${NC}: ${doc}.tex (PID: $!)"
    done
    
    # 等待所有进程完成
    local failed=0
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            echo -e "  ${GREEN}完成${NC}: ${docs[$i]}.pdf"
            ((SUCCESS_COUNT++))
        else
            echo -e "  ${RED}失败${NC}: ${docs[$i]}.tex"
            ((FAIL_COUNT++))
            ((failed++))
        fi
    done
    
    return $failed
}

# ───────────────────────────────────────────────────────────
# 文件监视
# ───────────────────────────────────────────────────────────

watch_files() {
    if ! command -v inotifywait &> /dev/null; then
        log_error "需要安装 inotify-tools"
        echo "  安装命令: sudo dnf install inotify-tools"
        exit 1
    fi
    
    log_info "监视文件变化... (Ctrl+C 退出)"
    echo ""
    
    while true; do
        changed=$(inotifywait -qe modify --format '%f' *.tex *.cls 2>/dev/null)
        echo ""
        log_info "检测到变化: $changed"
        
        # 根据变化的文件决定编译哪个
        case "$changed" in
            *.cls)
                # 类文件变化，编译所有
                for doc in "${ALL_DOCS[@]}"; do
                    quick_compile "$doc" false
                done
                ;;
            *.tex)
                # tex 文件变化，只编译对应文档
                local doc="${changed%.tex}"
                if [ -f "$changed" ]; then
                    quick_compile "$doc" false
                fi
                ;;
        esac
        echo ""
    done
}

# ───────────────────────────────────────────────────────────
# 主程序
# ───────────────────────────────────────────────────────────

main() {
    local mode="full"
    local docs=()
    local view=false
    local save_log=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean_temp
                exit 0
                ;;
            -C|--cleanall)
                clean_all
                exit 0
                ;;
            -q|--quick)
                mode="quick"
                shift
                ;;
            -f|--full)
                mode="full"
                shift
                ;;
            -p|--parallel)
                mode="parallel"
                shift
                ;;
            -v|--view)
                view=true
                shift
                ;;
            -l|--log)
                save_log=true
                mkdir -p "$LOG_DIR"
                shift
                ;;
            -w|--watch)
                watch_files
                exit 0
                ;;
            --check)
                check_env
                exit 0
                ;;
            all)
                docs=("${ALL_DOCS[@]}")
                shift
                ;;
            demo)
                docs+=("mindflow_demo")
                shift
                ;;
            notes)
                docs+=("mathnotes")
                shift
                ;;
            book)
                docs+=("mathbook")
                shift
                ;;
            report)
                docs+=("mathreport")
                shift
                ;;
            *)
                # 尝试作为文件名
                if [ -f "$1.tex" ]; then
                    docs+=("$1")
                    shift
                else
                    log_error "未知选项或文件不存在: $1"
                    echo "使用 ./build.sh --help 查看帮助"
                    exit 1
                fi
                ;;
        esac
    done
    
    # 默认编译所有
    if [ ${#docs[@]} -eq 0 ]; then
        docs=("${ALL_DOCS[@]}")
    fi
    
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     MindFlow LaTeX 编译系统 v2.0      ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    # 执行编译
    case "$mode" in
        quick)
            log_info "模式: 快速编译"
            for doc in "${docs[@]}"; do
                [ -f "${doc}.tex" ] && quick_compile "$doc" "$save_log"
            done
            ;;
        full)
            log_info "模式: 完整编译"
            for doc in "${docs[@]}"; do
                [ -f "${doc}.tex" ] && full_compile "$doc" "$save_log"
            done
            ;;
        parallel)
            log_info "模式: 并行编译"
            parallel_compile "${docs[@]}"
            ;;
    esac
    
    # 打开 PDF
    if $view; then
        for doc in "${docs[@]}"; do
            if [ -f "${doc}.pdf" ]; then
                log_info "打开 ${doc}.pdf..."
                xdg-open "${doc}.pdf" 2>/dev/null &
            fi
        done
    fi
    
    # 显示统计
    echo ""
    echo "────────────────────────────────────────"
    show_duration
    echo -e "📊 统计: ${GREEN}成功 $SUCCESS_COUNT${NC} | ${RED}失败 $FAIL_COUNT${NC}"
    echo ""
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 编译任务完成!${NC}"
    else
        echo -e "${YELLOW}⚠️  部分文档编译失败${NC}"
        exit 1
    fi
}

# 运行
main "$@"

#!/usr/bin/env bash
set -u

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[*]${NC} $1"; }
err()  { echo -e "${RED}[-]${NC} $1"; }

MANIFEST_URL="https://raw.githubusercontent.com/alsosram/deb-toolkit/master/tools.json"

usage() {
    cat <<EOF
Usage: bash install.sh [options]

Options:
  --list          List available tools and exit
  <number>        Run a specific tool by number (non-interactive)
  --help          Show this help
EOF
    exit 0
}

[[ $# -ge 1 && "$1" == "--help" ]] && usage

# Fetch toolbox manifest
TOOLS=()
while IFS='|' read -r name desc url; do
    TOOLS+=("$name|$desc|$url")
done < <(curl -fsSL "$MANIFEST_URL" 2>/dev/null | python3 -c "
import sys, json
for t in json.load(sys.stdin):
    print(t['name'] + '|' + t['desc'] + '|' + t['url'])
" 2>/dev/null)

if [[ ${#TOOLS[@]} -eq 0 ]]; then
    err "Failed to fetch toolbox manifest."
    err "Try again or manually run a tool:"
    echo "  curl -fsSL https://raw.githubusercontent.com/alsosram/deb-auto/main/install.sh | bash"
    exit 1
fi

[[ $# -ge 1 && "$1" == "--list" ]] && {
    info "Available tools:"
    for i in "${!TOOLS[@]}"; do
        IFS='|' read -r name desc _ <<< "${TOOLS[$i]}"
        echo "  $((i+1))) $name — $desc"
    done
    exit 0
}

show_banner() {
    clear
    echo -e "${GREEN}"
    echo '  ╔══════════════════════════════════════╗'
    echo '  ║         Debian Tool Kit              ║'
    echo '  ║     Interactive Tool Launcher        ║'
    echo '  ╚══════════════════════════════════════╝'
    echo -e "${NC}"
}

show_menu() {
    echo ""
    info "Select a tool to run:"
    echo ""
    for i in "${!TOOLS[@]}"; do
        IFS='|' read -r name desc _ <<< "${TOOLS[$i]}"
        printf "  ${GREEN}[%d]${NC} ${BOLD}%-15s${NC} %s\n" $((i+1)) "$name" "$desc"
    done
    echo ""
    printf "  ${CYAN}[Q]${NC} Quit${NC}\n"
    echo ""
}

run_tool() {
    local idx=$1
    IFS='|' read -r name desc url <<< "${TOOLS[$idx]}"
    local full_url="https://raw.githubusercontent.com/alsosram/$url"

    echo ""
    log "Starting: $name"
    info "$desc"
    echo ""
    warn "This tool will be downloaded from GitHub and executed."
    warn "Inspect it first: $full_url"
    echo ""

    read -rp "  Download and run now? [Y/n]: " ans
    if [[ "$ans" != "n" && "$ans" != "N" ]]; then
        bash <(curl -fsSL "$full_url") < /dev/tty
    else
        log "Skipped."
    fi
    echo ""
}

# --- Main ---
show_banner

if [[ $# -ge 1 ]]; then
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        idx=$(( $1 - 1 ))
        if [[ $idx -ge 0 && $idx -lt ${#TOOLS[@]} ]]; then
            run_tool $idx
            exit 0
        fi
    fi
    err "Invalid option: $1"
    usage
fi

while true; do
    show_menu
    read -rp "  Enter choice [1-${#TOOLS[@]}]: " choice
    case "$choice" in
        [Qq]) log "Goodbye."; exit 0 ;;
        * )
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                idx=$(( choice - 1 ))
                if [[ $idx -ge 0 && $idx -lt ${#TOOLS[@]} ]]; then
                    run_tool $idx
                else
                    err "Invalid number."
                fi
            else
                err "Invalid input."
            fi
            ;;
    esac
    echo ""
    read -rp "  Press Enter to continue..."
done

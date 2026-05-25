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

if ! command -v whiptail &>/dev/null; then
    echo "[!] whiptail is required. Install: apt-get install whiptail" >&2
    exit 1
fi

while true; do
    menu_args=()
    menu_args+=("--menu" "Select a tool to run:" "18" "70" "${#TOOLS[@]}")
    for i in "${!TOOLS[@]}"; do
        IFS='|' read -r name desc _ <<< "${TOOLS[$i]}"
        menu_args+=("$((i+1))" "${name} — ${desc}")
    done
    menu_args+=("Q" "Quit")

    choice=$(whiptail "${menu_args[@]}" 3>&1 1>&2 2>&3) || {
        log "Goodbye."
        exit 0
    }
    if [[ "$choice" == "Q" ]]; then
        log "Goodbye."
        exit 0
    fi
    idx=$(( choice - 1 ))
    run_tool $idx
    if [[ -t 0 ]]; then
        read -rp "  Press Enter to continue..."
    fi
done

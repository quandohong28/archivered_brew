#!/usr/bin/env bash

# ----- Colors -----
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

log_info()  { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${RESET} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_err()   { echo -e "${RED}[ERR]${RESET} $1"; }
log_dry()   { echo -e "${BLUE}[DRY]${RESET} $1"; }

# ----- Default config -----
MACOS_VERSION="catalina"
LOCAL_INSTALL="false"
DRY_RUN="false"

# ----- Wrapper -----
run_cmd() {
  if [ "$DRY_RUN" == "true" ]; then
    log_dry "$*"
  else
    eval "$@"
  fi
}

# ----- Parse args -----
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      MACOS_VERSION="$2"
      shift 2
      ;;
    --local)
      LOCAL_INSTALL="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    *)
      log_err "Unknown option $1"
      exit 1
      ;;
  esac
done

# ----- Map macOS version -> Homebrew installer commit hash -----
declare -A INSTALLER_MAP=(
  ["high_sierra"]="cb6aa2c1c55b59fba95a4a8cf1138b3d34908a5a"
  ["mojave"]="6f681f230cd0ab80239934a97cb5d384faa89f88"
  ["catalina"]="fcfea5bbf7130d754360d3056601bad131b09762"
  ["big_sur"]="7d8eb69dfe0b5bb9ad685e1113a33eaec2b71c88"
  ["monterey"]="38a0dc3eafe188c23983f379abdb43b1a50ed415"
  ["ventura"]="bce07c53def3dbe54aa14a88adfc63eb7ba91f48"
  ["sonoma"]="dc89d02c0107d688e089c1683dcda3401719f1f8"
)

INSTALLER_HASH="${INSTALLER_MAP[$MACOS_VERSION]}"

if [ -z "$INSTALLER_HASH" ]; then
  log_err "No installer mapped for macOS version: $MACOS_VERSION"
  log_info "Valid versions: ${!INSTALLER_MAP[@]}"
  exit 1
fi

log_info "Installing Homebrew for macOS $MACOS_VERSION..."

# ----- Run installer -----
if [ "$LOCAL_INSTALL" == "true" ]; then
  LOCAL_FILE="macos/${MACOS_VERSION}.sh"
  if [ -f "$LOCAL_FILE" ]; then
    log_info "Running local installer: $LOCAL_FILE"
    run_cmd "/bin/bash \"$LOCAL_FILE\""
  else
    log_err "Local installer not found: $LOCAL_FILE"
    exit 1
  fi
else
  run_cmd "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/$INSTALLER_HASH/install.sh)\""
fi

# ----- Sync core -----
log_info "Syncing Homebrew core..."
if command -v brew &>/dev/null; then
  CORE_REPO="$(brew --repo homebrew/core 2>/dev/null)"
  if [ -d "$CORE_REPO" ]; then
    run_cmd "cd \"$CORE_REPO\" && git fetch origin && git checkout main && git reset --hard origin/main"
  fi
else
  log_warn "brew not found in PATH yet. Skipping core sync."
fi

# ----- Update Homebrew -----
log_info "Updating Homebrew..."
run_cmd "brew update --quiet"

# ----- Doctor -----
log_info "Running brew doctor..."
run_cmd "brew doctor"

# ----- Untap local core -----
log_info "Untapping Homebrew/core..."
run_cmd "brew untap homebrew/core >/dev/null 2>&1 || true"

# ----- Ensure PATH -----
if ! command -v brew &>/dev/null; then
  log_warn "Homebrew installed but not in PATH."
  echo "       Add it with: echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.bashrc || ~/.zshrc"
  [ "$DRY_RUN" == "true" ] || exit 1
fi

log_ok "Homebrew installation & setup complete!"
run_cmd "brew --version"

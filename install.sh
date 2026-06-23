#!/usr/bin/env bash
# amux installer.  Copies the `amux` binary onto your PATH and (optionally)
# wires up shell integration.  No sudo needed for the default prefix.
#
#   ./install.sh                 # install to ~/.local/bin, offer shell setup
#   PREFIX=/usr/local ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="$PREFIX/bin"

say()  { printf '\033[36m▸\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }

# ---- dependencies -----------------------------------------------------------
if ! command -v tmux >/dev/null 2>&1; then
  warn "tmux not found — amux requires tmux. Install it first (brew/apt install tmux)."
fi
command -v fzf  >/dev/null 2>&1 || warn "fzf not found — the live picker falls back to a plain menu. (recommended: install fzf)"
command -v curl >/dev/null 2>&1 || warn "curl not found — the picker preview won't auto-refresh. (recommended: install curl)"

# ---- install the binary -----------------------------------------------------
mkdir -p "$BINDIR"
install -m 0755 "$REPO/bin/amux" "$BINDIR/amux"
ok "installed: $BINDIR/amux"

case ":$PATH:" in
  *":$BINDIR:"*) : ;;
  *) warn "$BINDIR is not on your PATH. Add this to your shell rc:"
     printf '      export PATH="%s:$PATH"\n' "$BINDIR" ;;
esac

# ---- shell integration ------------------------------------------------------
detect_rc() {
  case "${SHELL##*/}" in
    zsh)  printf '%s\n' "${ZDOTDIR:-$HOME}/.zshrc" ;;
    bash) printf '%s\n' "$HOME/.bashrc" ;;
    *)    printf '' ;;
  esac
}
shell_file() {
  case "${SHELL##*/}" in zsh) printf '%s\n' "$REPO/shell/amux.zsh" ;; bash) printf '%s\n' "$REPO/shell/amux.bash" ;; *) printf '' ;; esac
}

RC="$(detect_rc)"; SRC="$(shell_file)"
LINE="source \"$SRC\"   # amux"

if [ -n "$RC" ] && [ -n "$SRC" ]; then
  if [ -f "$RC" ] && grep -qF "$SRC" "$RC" 2>/dev/null; then
    ok "shell integration already present in $RC"
  else
    say "Optional shell integration (completion + optional SSH menu):"
    printf '      %s\n' "$LINE"
    if [ -t 0 ]; then
      printf '   Add it to %s now? [y/N] ' "$RC"
      read -r ans
      case "$ans" in
        y|Y|yes)
          printf '\n# amux shell integration\n%s\n' "$LINE" >> "$RC"
          ok "added to $RC — restart your shell or: source \"$RC\"" ;;
        *) say "skipped — add the line above whenever you like." ;;
      esac
    fi
  fi
fi

printf '\n'
ok "done.  Try:  amux        (list)"
say "          amux pick   (picker)   ·   amux watch  (dashboard)"
say "Korean UI:  export AMUX_LANG=ko        Config: amux --help"

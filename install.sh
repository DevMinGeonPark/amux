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
MARK_START='# >>> amux >>>'
MARK_END='# <<< amux <<<'

# Append a self-contained managed block to the shell rc: PATH (if missing),
# optional SSH auto-picker, and `source` of the integration file (completion).
write_block() {
  local ssh_menu="$1"
  {
    printf '\n%s  (managed by amux install.sh)\n' "$MARK_START"
    case ":$PATH:" in *":$BINDIR:"*) : ;; *) printf 'export PATH="%s:$PATH"\n' "$BINDIR" ;; esac
    [ "$ssh_menu" = 1 ] && printf 'export AMUX_SSH_MENU=1   # auto-open the picker on SSH logins (outside tmux)\n'
    printf 'source "%s"\n' "$SRC"
    printf '%s\n' "$MARK_END"
  } >> "$RC"
}

if [ -n "$RC" ] && [ -n "$SRC" ]; then
  if [ -f "$RC" ] && grep -qF "$MARK_START" "$RC" 2>/dev/null; then
    ok "shell integration already present in $RC"
  elif [ -t 0 ]; then
    printf '   Add amux to %s (PATH + tab-completion)? [Y/n] ' "$RC"
    read -r ans
    case "$ans" in
      n|N|no) say "skipped — run amux by full path, or add $BINDIR to PATH yourself." ;;
      *)
        ssh=0
        printf '   Also auto-open the picker on SSH logins (outside tmux)? [y/N] '
        read -r a2; case "$a2" in y|Y|yes) ssh=1 ;; esac
        write_block "$ssh"
        ok "added to $RC — restart your shell or: source \"$RC\""
        [ "$ssh" = 1 ] && say "SSH auto-picker enabled — new SSH logins drop into the picker." ;;
    esac
  else
    warn "non-interactive — add this to $RC to finish setup:"
    printf '      export PATH="%s:$PATH"\n' "$BINDIR"
    printf '      export AMUX_SSH_MENU=1   # optional: auto-open picker on SSH login\n'
    printf '      source "%s"\n' "$SRC"
  fi
fi

printf '\n'
ok "done.  Try:  amux        (list)"
say "          amux pick   (picker)   ·   amux watch  (dashboard)"
say "Korean UI:  export AMUX_LANG=ko        Config: amux --help"

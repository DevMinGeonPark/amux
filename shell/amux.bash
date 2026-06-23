# amux — bash integration.  Source this from your ~/.bashrc:
#     source /path/to/amux/shell/amux.bash
#
# Provides completion for `amux` and an optional SSH login menu
# (enable with:  export AMUX_SSH_MENU=1).
#
# Handy aliases (optional):
#   alias a='amux attach'
#   alias aw='amux watch'

# If `amux` isn't already on PATH, add the bin dir next to this file.
if ! command -v amux >/dev/null 2>&1; then
  _amux_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  [ -x "$_amux_here/../bin/amux" ] && PATH="$_amux_here/../bin:$PATH"
  unset _amux_here
fi

_amux() {
  local cur="${COMP_WORDS[COMP_CWORD]}" names
  names="$(command tmux list-sessions -F '#{session_name}' 2>/dev/null | sed 's#.*/##' | sort -u)"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "list pick watch attach ssh-menu --help $names" -- "$cur") )
  elif [ "${COMP_WORDS[1]}" = attach ] || [ "${COMP_WORDS[1]}" = a ]; then
    COMPREPLY=( $(compgen -W "$names" -- "$cur") )
  fi
}
complete -F _amux amux 2>/dev/null

# Optional: show the picker on interactive SSH logins (outside tmux).
case $- in *i*)
  if [ -n "${AMUX_SSH_MENU:-}" ] && [ -z "${TMUX:-}" ] && [ -z "${AMUX_SSH_RAN:-}" ] \
     && { [ -n "${SSH_TTY:-}" ] || [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ]; }; then
    export AMUX_SSH_RAN=1
    amux ssh-menu
  fi
;; esac

# amux — zsh integration.  Source this from your ~/.zshrc:
#     source /path/to/amux/shell/amux.zsh
#
# Provides:
#   • completion for `amux` (subcommands + session short-names for `attach`)
#   • an optional SSH login menu — enable by also setting:  export AMUX_SSH_MENU=1
#
# Handy aliases (optional — add to your ~/.zshrc if you like):
#   alias a='amux attach'    # a api  → attach <tag>/api
#   alias aw='amux watch'    # live dashboard

# If `amux` isn't already on PATH, add the bin dir next to this file.
if ! command -v amux >/dev/null 2>&1; then
  _amux_here="${${(%):-%x}:A:h}"
  [[ -x "$_amux_here/../bin/amux" ]] && path=("$_amux_here/../bin" $path)
  unset _amux_here
fi

_amux() {
  local -a subs names
  subs=(list pick watch attach ssh-menu --help)
  names=(${(f)"$(command tmux list-sessions -F '#{session_name}' 2>/dev/null | sed 's#.*/##' | sort -u)"})
  if (( CURRENT == 2 )); then
    compadd -- $subs $names
  elif [[ ${words[2]} == (attach|a) ]]; then
    compadd -- $names
  fi
}
compdef _amux amux 2>/dev/null

# Optional: show the picker on interactive SSH logins (outside tmux).
if [[ -o interactive && -n "${AMUX_SSH_MENU:-}" && -z "${TMUX:-}" \
      && ( -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" || -n "${SSH_CLIENT:-}" ) \
      && -z "${AMUX_SSH_RAN:-}" ]]; then
  export AMUX_SSH_RAN=1
  amux ssh-menu
fi

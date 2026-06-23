# amux demo — rendered with `vhs docs/demo/demo.tape` from the repo root.
# Builds throwaway sessions on an isolated tmux server (docs/demo/setup.sh),
# then shows the list view and the live fzf picker. No real/private content.

Output docs/demo.gif

Set Shell bash
Set FontSize 17
Set Width 1500
Set Height 860
Set Padding 18
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms

# ---- hidden setup: isolated server + fake agent sessions -------------------
Hide
Type "export TMUX_TMPDIR=/tmp/amux-demo AMUX_LANG=en PATH=$PWD/bin:$PATH" Enter
Type "rm -rf /tmp/amux-demo && mkdir -p /tmp/amux-demo" Enter
Type "bash docs/demo/setup.sh >/dev/null 2>&1" Enter
Sleep 1500ms
Type "clear" Enter
Show

# ---- 1. list view: summary bar + tag groups + tool/status ------------------
Type "amux" Enter
Sleep 4s

# ---- 2. live picker: real-screen preview, attention-first ordering ---------
Type "amux pick" Enter
Sleep 2500ms
Down@900ms
Sleep 1800ms
Down@900ms
Sleep 1800ms
Down@900ms
Sleep 1800ms
Up@900ms
Sleep 1500ms
Escape
Sleep 800ms

# ---- tidy exit -------------------------------------------------------------
Hide
Type "tmux -u kill-server 2>/dev/null; clear" Enter
Sleep 500ms

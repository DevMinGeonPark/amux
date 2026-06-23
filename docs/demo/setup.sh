#!/usr/bin/env bash
# Build a set of throwaway demo sessions on an ISOLATED tmux server
# (via $TMUX_TMPDIR) with crafted, fake agent screens — so the README GIF
# shows every status with zero real/private content.
#
# Caller must export TMUX_TMPDIR (and run amux with the same value).
set -u
T=(tmux -u)

"${T[@]}" kill-server 2>/dev/null
sleep 0.3

NBSP=$(printf '\302\240')   # the U+00A0 Claude uses before input text

# spawn <name> <title> — create a session whose foreground process looks like
# `claude` (or codex), then paint <stdin> as its screen and set the title.
spawn() {
  local name="$1" title="$2" prog="${3:-claude}" body; body="$(cat)"
  "${T[@]}" new-session -d -s "$name" -x 200 -y 50
  "${T[@]}" send-keys -t "$name" "clear; cat <<'SCREEN'
$body
SCREEN
bash -c 'exec -a $prog sleep 100000'" Enter
  sleep 0.15
  "${T[@]}" select-pane -t "$name" -T "$title"
}

# ── working (busy): braille spinner title ────────────────────────────────────
spawn "api/worker" "⠙ Refactoring the auth middleware" <<'EOF'
● I'll extract the token-verification logic into its own module and add tests.

  Updating  src/auth/verify.ts
  Updating  src/auth/verify.test.ts
✻ Cooking…
EOF

# ── needs you (block): permission box at the bottom ──────────────────────────
spawn "api/server" "✳ Deploy the staging build" <<EOF
● Ready to deploy. This will push the current build to staging.

╭─────────────────────────────────────────────╮
│ Do you want to proceed?                     │
│                                             │
│ ❯ 1. Yes                                    │
│   2. Yes, and don't ask again               │
│   3. No, and tell Claude what to do (esc)   │
╰─────────────────────────────────────────────╯
EOF

# ── asking: last message is a question, idle at the prompt ───────────────────
spawn "web/ui" "✳ Build the settings page" <<EOF
● The settings page can use a tabbed layout or a single scroll. Tabs scale
  better as we add sections, but scroll is simpler for now.

  Which approach do you prefer — tabs or single scroll?

─────────────────────────────────────────────────────────────
❯
─────────────────────────────────────────────────────────────
  📁 web-ui │ 🤖 Opus 4.8
  ⏵⏵ bypass permissions on
EOF

# ── typing (draft): text already in the input box ───────────────────────────
spawn "web/api" "✳ Add response caching" <<EOF
● Where should I add the cache — at the route layer or inside the service?

─────────────────────────────────────────────────────────────
❯${NBSP}at the service layer, with a short TTL
─────────────────────────────────────────────────────────────
  📁 web-api │ 🤖 Opus 4.8
  ⏵⏵ bypass permissions on
EOF

# ── idle: quietly waiting ────────────────────────────────────────────────────
spawn "infra/logs" "✳ Claude Code" <<EOF
● Done. Log rotation is configured and the old archives are cleaned up.

─────────────────────────────────────────────────────────────
❯
─────────────────────────────────────────────────────────────
  📁 infra │ 🤖 Opus 4.8
  ⏵⏵ bypass permissions on
EOF

# ── codex (run): a non-Claude agent ─────────────────────────────────────────
spawn "data/etl" "codex" codex <<EOF
> building the nightly aggregation pipeline…
  • parsed schema
  • wiring transforms
EOF

sleep 0.3

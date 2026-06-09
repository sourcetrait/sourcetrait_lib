#!/usr/bin/env bash
# Claude Code statusline wrapper.
#
# Renders the statusline (unchanged from the original inline jq script) AND, as
# a fail-soft side-effect, writes a small per-session gap-fill JSON to
# ~/sys/.claude/state/statusline-<session_id>.json so the agent can introspect
# fields (effort_level, context-window %, rate limits) that aren't otherwise
# exposed in its per-turn context. The render is the primary concern; the
# write must never block it.

STATE_DIR="$HOME/sys/.claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

# Read stdin once; reuse for both consumers.
INPUT=$(cat)

# Side-effect: write per-session gap-fill JSON. Fail-soft.
{
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // .session.id // "unknown"' 2>/dev/null) || SID=unknown
  printf '%s' "$INPUT" | jq '{
    effort_level: (.effort.level // null),
    context_window,
    rate_limits
  }' > "$STATE_DIR/statusline-$SID.json" 2>/dev/null
} 2>/dev/null || true

# Primary: render the statusline (unchanged from the original inline command).
printf '%s' "$INPUT" | TZ="${ALT_TZ:-UTC}" jq -r '(if .workspace.project_dir != null then "\(.workspace.project_dir | split("/") | last): " else "" end) + ([.model.display_name, (if .effort.level then "(\(.effort.level))" else empty end), (if .context_window.used_percentage != null then "\(.context_window.used_percentage)%" else empty end), (if .rate_limits.five_hour.used_percentage != null then (.rate_limits.five_hour as $fh | "[\($fh.used_percentage | floor)%" + (if $fh.resets_at != null then " " + ($fh.resets_at | localtime | strftime("%H%M")) else "" end) + "]") else empty end)] | join(" "))'

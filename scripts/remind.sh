#!/usr/bin/env bash
# SessionStart hook: tells Claude (not the writer directly) which of the writer's posts still have no
# final version, so it can mention /content-studio:final once. Prints nothing when there are none.
DIR="$HOME/.content-studio"
[ -s "$DIR/url" ] && [ -s "$DIR/key" ] || exit 0
URL="$(tr -d '\r\n ' < "$DIR/url")"; KEY="$(tr -d '\r\n ' < "$DIR/key")"
curl -sS -m 10 -H "Authorization: Bearer $KEY" "$URL/api/reminders" 2>/dev/null || true
exit 0

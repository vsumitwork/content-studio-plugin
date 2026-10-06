#!/usr/bin/env bash
# Stop hook: after each Claude turn, send any Content Studio post whose file changed since it was
# last sent. Silent, quick, never blocks Claude: every failure is ignored. The server keeps a
# revision only when the text really changed.
DIR="$HOME/.content-studio"
[ -s "$DIR/posts.tsv" ] && [ -s "$DIR/url" ] && [ -s "$DIR/key" ] || exit 0
URL="$(tr -d '\r\n ' < "$DIR/url")"; KEY="$(tr -d '\r\n ' < "$DIR/key")"
mkdir -p "$DIR/sync"
while IFS=$'\t' read -r id slug path title; do
  [ -n "$id" ] || continue
  path="${path%$'\r'}"
  command -v cygpath >/dev/null 2>&1 && path="$(cygpath -u "$path" 2>/dev/null || echo "$path")"
  [ -f "$path" ] || continue
  h="$(sha256sum "$path" | cut -d' ' -f1)"
  [ "$h" = "$(cat "$DIR/sync/$id" 2>/dev/null)" ] && continue
  code=$(curl -sS -m 15 -o /dev/null -w '%{http_code}' -X POST -H "Authorization: Bearer $KEY" \
    -H "Content-Type: text/markdown; charset=utf-8" --data-binary "@$path" "$URL/api/submissions/$id/revision" 2>/dev/null)
  case "$code" in 200|201) echo "$h" > "$DIR/sync/$id" ;; esac
done < "$DIR/posts.tsv"
exit 0

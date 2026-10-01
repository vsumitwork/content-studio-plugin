#!/usr/bin/env bash
# One call to the Content Studio server, with the writer's personal key.
#
#   cs.sh GET  /api/me
#   cs.sh GET  "/api/rules/guest-posts?client=enthral-ai&format=md"  ~/.content-studio/work/rules.md
#   cs.sh POST /api/check  ~/.content-studio/work/check.json
#   cs.sh POST /api/submissions  ~/.content-studio/work/submission.json  ~/.content-studio/work/saved.json
#
# GET:  3rd argument (optional) = file to save the reply in.
# POST: 3rd argument = JSON file with the request body (always a file: inline JSON gets its
#       dashes and quotes mangled by the Windows shell); 4th (optional) = file to save the reply in.
# The last line printed is always "HTTP <status>".
set -uo pipefail
DIR="$HOME/.content-studio"
if [ ! -s "$DIR/url" ] || [ ! -s "$DIR/key" ]; then
  echo "Content Studio is not set up yet. Run /content-studio:setup first."
  echo "HTTP 000"
  exit 2
fi
URL="$(tr -d '\r\n ' < "$DIR/url")"
KEY="$(tr -d '\r\n ' < "$DIR/key")"
METHOD="$1"; PATH_Q="$2"
mkdir -p "$DIR/work"

if [ "$METHOD" = "GET" ]; then
  OUT="${3:-}"
  if [ -n "$OUT" ]; then
    code=$(curl -sS -o "$OUT" -w '%{http_code}' -H "Authorization: Bearer $KEY" "$URL$PATH_Q")
    [ "$code" = "200" ] && echo "Saved to $OUT ($(wc -c < "$OUT") bytes)" || cat "$OUT"
    echo; echo "HTTP $code"
  else
    curl -sS -w '\nHTTP %{http_code}\n' -H "Authorization: Bearer $KEY" "$URL$PATH_Q"
  fi
else
  BODY="${3:?POST needs a JSON body file}"
  OUT="${4:-}"
  if [ -n "$OUT" ]; then
    code=$(curl -sS -o "$OUT" -w '%{http_code}' -X "$METHOD" -H "Authorization: Bearer $KEY" \
      -H "Content-Type: application/json; charset=utf-8" --data-binary "@$BODY" "$URL$PATH_Q")
    cat "$OUT"; echo; echo "HTTP $code"
  else
    curl -sS -w '\nHTTP %{http_code}\n' -X "$METHOD" -H "Authorization: Bearer $KEY" \
      -H "Content-Type: application/json; charset=utf-8" --data-binary "@$BODY" "$URL$PATH_Q"
  fi
fi

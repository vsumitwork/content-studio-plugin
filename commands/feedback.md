---
description: Send a client writer's comments on a Content Studio post (e.g. Doc comments), so the weekly learning can turn them into rules.
argument-hint: "[paste the comments]"
allowed-tools: Bash(bash:*) Bash(curl:*) Read Write
---

Send client feedback on a Content Studio post.

1. Find the post exactly as `/content-studio:final` does (from `~/.content-studio/posts.tsv`, or
   `GET /api/submissions`). Ask which post if it is not clear.
2. The comments are in `$ARGUMENTS`, or ask the writer to paste them. Keep them word for word;
   include the text each comment was on, if they have it. Ask who sent them (e.g. "Mitali, client
   writer") if not stated.
3. Write `~/.content-studio/work/feedback.json`:
   `{"submission_id": "<id>", "text": "<the comments>", "from": "<who>"}` and run
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/feedback ~/.content-studio/work/feedback.json`
4. On `HTTP 200` say "Feedback saved for <title>." If the feedback asks for changes to the post,
   offer to make them (then re-check with the write-content skill's step 5).

---
description: Send the delivered (final) version of a post you wrote with Content Studio, so the weekly learning can compare it with the draft.
argument-hint: "[file path, or paste the final post]"
allowed-tools: Bash(bash:*) Bash(curl:*) Read Write
---

Send the final, delivered version of a Content Studio post.

1. Find the post. Read `~/.content-studio/posts.tsv` (lines: id, slug, path, title). If
   `$ARGUMENTS` names a file or a title, match it; otherwise list the 10 most recent and ask which.
   If the file is missing or empty, run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET /api/submissions`
   and pick from the writer's posts there.
2. Get the final text: a file path in `$ARGUMENTS`, text pasted in `$ARGUMENTS`, or ask the writer
   to paste it now. It must be the version that was actually delivered, with its `#` headings
   (if they paste plain text from Google Docs, ask which lines are headings and add `#`/`##`).
3. Write `~/.content-studio/work/final.json`: `{"markdown": "<the final post>"}` and run
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/submissions/<id>/final ~/.content-studio/work/final.json`
4. On `HTTP 200` say "Final version saved for <title>. Thank you: this is what makes next month's
   drafts need less editing." Otherwise show the error.

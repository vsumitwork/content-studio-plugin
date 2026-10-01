---
description: Connect Claude to Content Studio (once). Paste the server address and your personal key from the website's "Use in Claude" page.
argument-hint: "[server address] [key]"
allowed-tools: Bash(bash:*) Bash(curl:*) Bash(mkdir:*) Write
---

Set up the Content Studio plugin for this writer.

1. The server address and the personal key come from the Content Studio website, page
   **Use in Claude** (https://content-studio.pages.dev/#/claude). If they are not both in
   `$ARGUMENTS`, ask for them: the address starts with `https://`, the key starts with `cs_`.
2. Write the address (no trailing `/`) to `~/.content-studio/url` and the key to
   `~/.content-studio/key` with the Write tool, each on one line, nothing else in the file.
   (`~` is the writer's home folder, e.g. `C:\Users\<name>`.)
3. Test it: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET /api/me`
   - `HTTP 200`: say "Connected as <email>. Ask me to write a tips blog or a guest post, for
     example: Write a guest post for Enthral, keyword 'lms for compliance training'."
   - `HTTP 401`: the key is wrong or revoked; ask them to create a new one on the website.
   - anything else: show the reply and ask them to check the address.

Never print the key back in full; refer to it as `cs_…` plus its last 4 characters.

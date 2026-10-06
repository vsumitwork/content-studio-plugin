---
name: write-content
description: Write a Wildnet post (a WildnetEdge tips blog, or a guest post for any Content Studio client such as Enthral.ai or Cloudnine) that follows the Content Studio house rules. Use whenever the user asks to write, draft or revise a tips blog, guest post or blog for a client, or mentions Content Studio. Fetches the current rules and research brief, writes the post, checks it against the house gates, fixes what fails, saves it and records it.
allowed-tools: Bash(bash:*) Bash(curl:*) Bash(mkdir:*) Read Write Edit WebSearch WebFetch
---

# Write a post with Content Studio

The house rules live on the Content Studio server, not in this plugin, so they are always the
current ones. Every server call goes through the plugin's script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" <GET|POST> <path> [file] [file]
```

Its last line is `HTTP <status>`. Request bodies are **always** a JSON file you write with the
Write tool into `~/.content-studio/work/` (never inline JSON in the command: the Windows shell
mangles dashes and quotes). If any call says "not set up yet" or returns `HTTP 401`, tell the
writer to run `/content-studio:setup` and stop.

## 1. Collect the inputs

| Field | Needed | Notes |
|---|---|---|
| client | yes | One of the clients the server knows (see below). |
| line | yes | The content type: `tips-blogs` (WildnetEdge only) or `guest-posts` (any other client) |
| primary keyword | yes | lower case |
| secondary keywords | no | |
| title | no | if missing, you pick one containing the primary keyword |
| internal link | no | the exact URL the writer gives; never invent one |
| country | no | default `United States` |

First run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET /api/config`. Its `clients` list has each
client's `name` (what the API wants, e.g. `enthral-ai`) and `label` ("Enthral.ai"), and `lines`
says which content types each client takes. Match what the writer said to a client. If the client
is not in the list, say so and stop: new clients are added on the website (Clients → New client,
with their website and 2-5 approved sample posts), so their style is learned first.

Ask for anything required that is missing, in one question. Do not guess the client or keyword.

## 2. Get the rules

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET "/api/rules/<line>?client=<client>&format=md" ~/.content-studio/work/rules.md
```

Read `~/.content-studio/work/rules.md` in full. It has the house rules, the checks the post must
pass, and the task template. Note the `rules_version` on its first line. **Follow these rules over
anything you would normally do.** The precedence rule inside it is binding: the research brief
decides what to cover, the rules decide how, and the writer's inputs beat both.

## 3. Get the research brief

URL-encode the keyword and country (spaces as `%20`):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET "/api/brief?keyword=<kw>&country=<country>&format=md" ~/.content-studio/work/brief.md
```

- `HTTP 200`: read the brief. Its front matter says `quality: full` or `quality: quick`.
- `HTTP 404`: ask the writer: *"There is no research brief for this keyword yet. Full research
  (about 2-3 minutes, best) or quick research (about 1 minute, lighter)?"* For a guest post they
  may also say none; a tips blog needs research.
  - **Full:** write `{"keyword": "<kw>", "country": "<country>", "mode": "full"}` to
    `~/.content-studio/work/research.json`, then
    `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/research ~/.content-studio/work/research.json`.
    The reply has `job_id` (or `brief_exists: true`: fetch the brief again). Then every 15 seconds
    (`sleep 15` before each call) run
    `bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET /api/research/<job_id>` and tell the writer the
    `detail` line, e.g. "Reading the top 10 pages (2 of 5)", and the elapsed time. When `status` is
    `done`, fetch the brief again. When it is `failed`, show the `message` and offer quick research.
    A `429` means the daily limit is reached: offer quick research.
  - **Quick:** use the `quick-research` skill, then fetch the brief again.

Remember which research you ended with: `full`, `quick` or `none`.

## 4. Write the post

Fill the task template at the end of `rules.md` with the inputs and write the post yourself,
following every rule in `rules.md` and covering what the brief says to cover. Keep any
`[verify before publishing]` mark on a stat. Write it to `<slug>.md` in the writer's current
folder (`slug` = the title or keyword in lower case, words joined with `-`). The file starts with
`# <title>` and contains only the post.

## 5. Check it, and fix what fails (up to 2 rounds)

Write `~/.content-studio/work/check.json`:

```json
{"line": "<line>", "client": "<client>", "keyword": "<primary>", "secondary_keywords": ["<kw2>"], "markdown": "<the whole post>"}
```

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/check ~/.content-studio/work/check.json
```

The reply has `pass`, `gates` (each `ok` or not, with `value` and `target`) and `fix_prompt`.
If `pass` is false, revise the post to fix **only** what `fix_prompt` lists, save the file, and check
again. Stop after 2 fix rounds. Count the rounds you did.

## 6. Record it

Write `~/.content-studio/work/submission.json`:

```json
{"line": "<line>", "client": "<client>", "keyword": "<primary>", "secondary_keywords": [],
 "title": "<title>", "internal_link": "<url or empty>", "country": "<country>", "route": "plugin",
 "research_quality": "full|quick|none", "fix_rounds": <n>, "used_anyway": <true if still failing>,
 "rules_version": "<from rules.md>", "markdown": "<the final post>"}
```

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/submissions ~/.content-studio/work/submission.json
```

The reply has the submission `id`. Append one line to `~/.content-studio/posts.tsv`:
`<id><TAB><slug><TAB><full path of the .md><TAB><title>` (create the file if needed). The
`/content-studio:final` and `/content-studio:feedback` commands use it to find the post later.

## 7. Tell the writer

- where the file is (full path)
- the checks: all green, or which are still red after 2 rounds and why
- research used (full / quick / none) and the rules version
- *"When the post is delivered, run /content-studio:final and paste the delivered version. That is
  how the system learns."*

## Later edits

When the writer asks for changes to a post you wrote, make them, save the file, run step 5 again
on the new version, and report the checks. Do not create a new submission for edits; the delivered
version goes in with `/content-studio:final`.

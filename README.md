# Content Studio plugin for Claude

The Claude Code / Claude desktop app plugin for Wildnet's **Content Studio**. Writers with paid
Claude ask for a tips blog or a guest post in plain words; the plugin fetches the current house
rules and research brief from the Content Studio server, Claude writes the post, the server checks
it against the house gates, Claude fixes what fails, and the post is saved and recorded.

**Writers: start with [PLUGIN-SETUP.md](PLUGIN-SETUP.md).**

This repo is public on purpose. It contains no rules, no client facts and no secrets: those live on
the Content Studio server (private repo `vsumitwork/content-studio`) and reach Claude only through
a writer's personal key. That is also why the rules are always current without reinstalling.

## What is in it

| Path | What it does |
|---|---|
| `skills/write-content/` | The main flow: inputs, `GET /api/rules`, `GET /api/brief` (or research), write, `POST /api/check` with up to 2 fix rounds, save `<slug>.md`, `POST /api/submissions` |
| `skills/quick-research/` | Free research with Claude's own web search, in the server's brief format, saved with `POST /api/brief` |
| `commands/setup.md` | `/content-studio:setup`: stores the server address and key in `~/.content-studio/` |
| `commands/final.md` | `/content-studio:final`: the delivered version of a post |
| `commands/feedback.md` | `/content-studio:feedback`: a client writer's comments |
| `scripts/cs.sh` | The one place a server call is made (`curl`, built into Windows 10/11; Claude Code runs it in Git Bash) |

Local state on the writer's PC: `~/.content-studio/url`, `key`, `posts.tsv` (id, slug, path,
title of each post written) and `work/` (request bodies and downloaded rules; safe to delete).

## Install

```
/plugin marketplace add vsumitwork/content-studio-plugin
/plugin install content-studio@content-studio-plugin
```

Developing: `claude --plugin-dir <this folder>` loads it without installing, and
`claude plugin validate .` checks the manifests.

## Changing it

The plugin and the website must stay on the same server API (see the Content Studio repo's
`spec.md` §7 and `worker/src/index.js`). Bump `version` in `.claude-plugin/plugin.json` on every
change so installed copies update.

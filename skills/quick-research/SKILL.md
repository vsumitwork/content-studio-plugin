---
name: quick-research
description: Free, lighter research for a Content Studio keyword when no research brief exists and the writer chose quick research. Searches the web with Claude's own search, writes a brief in the Content Studio format, and saves it to the server so everyone can reuse it. Used by the write-content skill; can also be asked for directly ("quick research for <keyword>").
allowed-tools: Bash(bash:*) Bash(curl:*) Read Write WebSearch WebFetch
---

# Quick research

1. Get the research prompt (URL-encode keyword and country, spaces as `%20`):

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" GET "/api/prompts/quick-research?keyword=<kw>&country=<country>&format=md" ~/.content-studio/work/quick-prompt.md
   ```

2. Read `~/.content-studio/work/quick-prompt.md` and do exactly what it says, using WebSearch and
   WebFetch. Tell the writer briefly what you are reading. Include a statistic only when you have
   the link to its primary source.

3. Write the brief with **exactly the seven `##` headings** the prompt gives, in order
   (`## 1. What Google shows` to `## 7. Who ranks`), starting with `# Research brief: <keyword>`.

4. Save it. Write `~/.content-studio/work/brief.json`:

   ```json
   {"keyword": "<keyword>", "country": "<country>", "markdown": "<the brief>"}
   ```

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/cs.sh" POST /api/brief ~/.content-studio/work/brief.json
   ```

   - `HTTP 200`: saved as a quick brief (a later full research run replaces it).
   - `HTTP 400` with `missing`: add the missing sections and save again.
   - `HTTP 409`: a full brief already exists; use that one instead.

5. Return to the writing step with the brief.

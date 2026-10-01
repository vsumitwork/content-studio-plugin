# Content Studio in Claude: setup

For Wildnet writers who have **paid Claude** (Pro, Max or Team) and use the **Claude desktop app**
or Claude Code. It takes about five minutes, once.

If you use free ChatGPT, free Claude, Gemini, or Claude in the web browser, you do not need this:
use the website instead, https://content-studio.pages.dev (New draft).

---

## What you need

- The Claude desktop app for Windows, signed in with your paid Claude account
  (download: https://claude.ai/download).
- Your Wildnet email, to sign in to the Content Studio website.

## Step 1. Open Claude's Code tab

1. Open the Claude desktop app.
2. Click **Code** at the top.
3. When it asks for a folder, pick the folder where you want your posts saved, for example
   `Documents\Posts`. (Create it first if you need to.) Every post you write is saved there as a
   `.md` file.

## Step 2. Install the plugin

In the message box at the bottom, type this line and press Enter:

```
/plugin marketplace add vsumitwork/content-studio-plugin
```

Then this line, and press Enter:

```
/plugin install content-studio@content-studio-plugin
```

If Claude asks where to install it, choose **user** (for you, in every folder). If it says to
restart, close and reopen the Claude app, then open the Code tab again in the same folder.

## Step 3. Connect it to your account

1. In your web browser, open https://content-studio.pages.dev/#/claude and sign in with your
   Wildnet email (you get a code by email).
2. Click **Create a key**. Copy the key it shows (it starts with `cs_`). It is shown only once.
3. Back in Claude, type `/content-studio:setup` and press Enter.
4. When Claude asks, paste the **server address** (shown on the same web page, under "Copy server
   address") and then the **key**.
5. Claude replies "Connected as <your email>". Done.

## Writing a post

Just ask, in plain words, for example:

> Write a guest post for Enthral, keyword "lms for compliance training", title "How an LMS Makes
> Compliance Training Stick", link https://www.enthral.ai/enthral-lms-agentic-ai/

> Write a tips blog for WildnetEdge, keyword "hire flutter app developers usa"

Claude gets the current house rules and the research brief, writes the post, checks it, fixes what
fails, and saves it in your folder. If there is no research yet for the keyword, it asks whether you
want **full** research (about 2-3 minutes) or **quick** research (about 1 minute).

To change a post, just ask ("make the intro shorter"). Claude re-checks it after every change.

## After the post is delivered

When the client has the post, send Content Studio the version that was actually delivered:

```
/content-studio:final
```

and paste the delivered text (or give the file). If the client's writer left comments:

```
/content-studio:feedback
```

and paste them. This is how the system learns: next month's drafts need less editing.

## If something goes wrong

| Claude says | Do this |
|---|---|
| "not set up yet" | Run `/content-studio:setup` (step 3). |
| HTTP 401 / key is wrong or revoked | Create a new key on the website and run `/content-studio:setup` again. |
| "/plugin" is not recognised | You are in the Chat tab or the web browser. Use the desktop app's **Code** tab. |
| Research failed | Choose quick research when Claude offers it. |

Lost your key, or left Wildnet? Revoke the key on the website's **Use in Claude** page. Sumit can
also revoke any key from the Admin page.

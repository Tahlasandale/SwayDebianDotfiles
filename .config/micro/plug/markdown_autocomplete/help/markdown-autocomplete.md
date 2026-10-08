# Markdown Autocomplete Plugin

Enhances Markdown authoring in Micro with context-aware completions, smart list handling, and configurable helpers.

## Quick Start
1. Install the plugin under `~/.config/micro/plug/markdown_autocomplete/` (see README for exact copy commands).
2. Restart Micro or run `Ctrl-E` → `reload`.
3. Open a Markdown file and start typing your usual syntax – completions trigger automatically.
4. Use `Ctrl-E markdown-autocomplete-status` to confirm the active options.

## Features
### Inline Formatting
- `**` → `**|**` (bold)
- `~~` → `~~|~~` (strikethrough)
- `` ` `` → `` `|` `` (inline code)
- `[` → `[|]()` (link)
- `![` → `![|]()` (image)
- ````` ``` ````` → ````` ```\n\n``` ````` (triple-backtick fences with the cursor on the blank line)
- `- [` → `- [ ] ` (task/check list prefix)

### Lists
- Press Enter after `1.` to insert `2. ` automatically (honors indentation).
- Press Enter after `-`, `*`, or `+` to repeat the bullet.
- Press Enter on an empty marker (`1.` or `-`) to exit the list (if cleanup is enabled).

### Auto-Pairing
Automatically inserts matching characters (when enabled): `()`, `{}`, `""`, `''`.

### Quality-of-Life
- Cursor is positioned inside the inserted scaffolding whenever possible.
- Completions are skipped if the closing characters already exist.
- All behavior is configurable via plugin options and commands.

## Commands
| Command | Description |
| --- | --- |
| `markdown-autocomplete-toggle` | Toggles infobar status messages (also updates `showMessages` option). |
| `markdown-autocomplete-set <option> <true|false>` | Sets one of the plugin options globally. Accepts `true/false`, `on/off`, `yes/no`, `1/0`. |
| `markdown-autocomplete-status` | Prints the current state of every option. |

## Options
Use `set`, `setlocal`, or the `markdown-autocomplete-set` command to control these switches. Defaults are listed below.

| Option | Default | Purpose |
| --- | --- | --- |
| `enableFormatting` | `true` | Master toggle for inline formatting completions. |
| `enableCodeBlocks` | `true` | Controls triple-backtick fence insertion. |
| `enableChecklists` | `true` | Controls the `- [ ]` checklist helper. |
| `enableAutoPairs` | `true` | Enables auto-pairing for parentheses/braces/quotes. |
| `enableLists` | `true` | Enables numbered/bullet continuation on Enter. |
| `enableListCleanup` | `true` | Removes dangling list markers when pressing Enter on an empty list line. |
| `showMessages` | `false` | Shows infobar notifications for plugin actions. |

Example (global):
```
set markdown_autocomplete.enableChecklists false
```
Example (buffer-only):
```
setlocal markdown_autocomplete.enableAutoPairs false
```

## Troubleshooting
- Run Micro with `micro -debug file.md` and inspect `~/log.txt` for `[markdown_autocomplete]` entries.
- If you see `markdown_autocomplete is not a plugin` in the log, ensure the directory name, `repo.json` `Name`, and Lua filename all match.
- Commands not found? Confirm the plugin reloaded via `Ctrl-E reload` and check `markdown-autocomplete-status` for output.

## Installation (Recap)
```
~/.config/micro/plug/markdown_autocomplete/
    markdown-autocomplete.lua
    repo.json
    help/
        markdown-autocomplete.md
```
Restart Micro after copying files so the plugin can re-register commands and help text.

# Markdown Autocomplete (Micro Plugin)

Markdown Autocomplete brings opinionated, context-aware completions to the [Micro](https://micro-editor.github.io/) terminal editor. It accelerates everyday Markdown authoring with inline formatting snippets, smart list continuation, optional code fences, and lightweight auto-pairing – all written in a single Lua file that Micro can load directly from your `~/.config/micro/plug` directory.

## Feature Highlights
- **Inline formatting shorthands** – type `**`, `~~`, `` ` ``, `[`, or `![` to expand to bold, strikethrough, inline code, links, and images with the cursor dropped at the right spot.
- **Code blocks & task lists** – typing ````` ``` ````` expands to a fenced block with a blank line ready for content, and `- [` becomes `- [ ] ` for checklists.
- **Auto-pairing** – parentheses, braces, double quotes, and single quotes are auto-inserted when appropriate (optional).
- **List continuation & cleanup** – hitting Enter after `1. Foo` inserts `2. `; Enter after `- Bar` (or `*` / `+`) repeats the bullet. Pressing Enter on an empty `1.` or `-` line removes the dangling marker so you can exit the list cleanly.
- **Status & configuration commands** – toggle notifications, set options, and inspect the current configuration from the command palette.

## Repository Layout
```
.
├── README.md
├── repo.json
├── markdown-autocomplete.lua
└── help/
    └── markdown-autocomplete.md
```
- `markdown-autocomplete.lua` – main plugin code.
- `repo.json` – metadata used by Micro's plugin manager/channel.
- `help/markdown-autocomplete.md` – in-editor help topic registered via `config.AddRuntimeFile`.

## Installation
1. Create the plugin directory (if it does not already exist):
   ```sh
   mkdir -p ~/.config/micro/plug/markdown_autocomplete/help
   ```
2. Copy the files from this repository:
   ```sh
   cp markdown-autocomplete.lua ~/.config/micro/plug/markdown_autocomplete/
   cp repo.json ~/.config/micro/plug/markdown_autocomplete/
   cp help/markdown-autocomplete.md ~/.config/micro/plug/markdown_autocomplete/help/
   ```
3. Restart Micro or run `Ctrl-E` → `reload` to load the plugin.
4. Optional: run Micro with `micro -debug file.md`, trigger a completion, and inspect `~/log.txt` to confirm `[markdown_autocomplete] init() called` appears.

## Commands
| Command | Description |
| --- | --- |
| `markdown-autocomplete-toggle` | Toggles infobar status messages (`showMessages` option). |
| `markdown-autocomplete-set <option> <true|false>` | Sets a plugin option globally (`true/false`, `on/off`, `yes/no`, `1/0`). |
| `markdown-autocomplete-status` | Prints the current value of every option. |

## Configuration Options
All options can be changed via `set`, `setlocal`, or the `markdown-autocomplete-set` command. Defaults are shown below.

| Option | Default | Purpose |
| --- | --- | --- |
| `enableFormatting` | `true` | Master toggle for inline formatting helpers. |
| `enableCodeBlocks` | `true` | Enables triple-backtick fence insertion. |
| `enableChecklists` | `true` | Enables auto-expansion of `- [ ] ` checkboxes. |
| `enableAutoPairs` | `true` | Enables auto-pairing for parentheses/braces/quotes. |
| `enableLists` | `true` | Enables numbered/bullet continuation when pressing Enter. |
| `enableListCleanup` | `true` | Removes empty list markers when you press Enter on them. |
| `showMessages` | `false` | Shows info-bar notifications for plugin actions. |

Examples:
```
set markdown_autocomplete.enableChecklists false
setlocal markdown_autocomplete.enableAutoPairs false
```

## Usage
- Open any Markdown file in Micro (`micro notes.md`).
- Type the formatting shorthands or list markers as usual; the plugin expands them automatically.
- Use the commands above to tailor the behavior to your current buffer or workspace.
- Access the bundled help topic inside Micro: `Ctrl-E help markdown-autocomplete`.

## Packaging / Submission
This repository already contains the files Micro expects. To distribute the plugin:
- Zip the directory and publish it (for example, attach to a GitHub release).
- Update `repo.json`'s `Website`/`Url` fields to point to your public repository or release archive before submitting to the [Micro plugin channel](https://github.com/micro-editor/plugin-channel).

## Development Notes
- Written for Micro ≥ 2.0.0 (see `repo.json` requirement).
- Pure Lua with no external dependencies.
- Tested on Micro 2.0.13 in a Linux environment.

Feel free to fork and extend with additional Markdown snippets (tables, headings, etc.). PRs and suggestions welcome!

# Obsidian Vault Setup

The project root is an Obsidian vault. All generated documents live in the basedir (resolved from `.btrs-config.json`, default `.local`) and can use wikilinks to reference source files anywhere in the project.

## First-run setup

Before generating any documents, check if the vault is initialized. If `.obsidian/` doesn't exist at the project root, create it with sensible defaults:

```bash
# Check if vault exists
if [ ! -d ".obsidian" ]; then
  mkdir -p .obsidian
fi
```

### Excluded folders

Create or update `.obsidian/app.json` to exclude noisy directories from indexing. Read the existing file if present and merge — don't overwrite user customizations.

Directories to exclude (if they exist in the project):

```json
{
  "userIgnoreFilters": [
    "node_modules/",
    ".git/",
    "dist/",
    "build/",
    ".output/",
    ".nuxt/",
    ".svelte-kit/",
    ".next/",
    ".cache/",
    "coverage/",
    "__pycache__/",
    "target/",
    "vendor/",
    ".terraform/",
    "*.min.js",
    "*.min.css",
    "*.map"
  ]
}
```

Only include entries for directories/patterns that actually exist in the project. Check first with `ls` or `test -d`.

### Gitignore

Check if `.obsidian/` is in `.gitignore`. If not, inform the user that they should add it — don't modify `.gitignore` automatically since that's a tracked file.

Suggest:
```
# Obsidian
.obsidian/
```

### Output directories

Ensure the output directories exist:
```bash
mkdir -p <basedir>/reviews
mkdir -p <basedir>/releases
mkdir -p <basedir>/tech-debt
```

## Wikilink conventions

### Linking to source files

Use standard wikilinks with the full path from project root:

```markdown
- [[src/components/Button.svelte]]
- [[src/api/endpoints/users.ts]]
- [[src/styles/variables.css]]
```

Obsidian resolves these as long as the file exists within the vault (project root). If a file has a common name that might be ambiguous, use the shortest unambiguous path.

### Linking between generated documents

Documents within the basedir can link to each other:

- Tech debt master list → detail files: `[[0012]]`
- Review → tech debt items created: `[[0012]]`
- Tech debt summary → detail files: `[[0012]]`
- Tech debt detail → related items: `[[0005]]`
- Tech debt detail → source files: `[[src/components/Button.svelte]]`

### Linking from reviews to source files

In MR reviews, reference the actual files being reviewed:

```markdown
> [!warning] [[src/components/Map/DroneMarker.svelte]]:42 — Missing cleanup
> The `$effect` on line 42 creates a subscription but...
```

This makes the file reference clickable in Obsidian while still being readable as plain text.

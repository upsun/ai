# Upsun for OpenCode

Complete guide for using Upsun with [OpenCode.ai](https://opencode.ai).

## Quick Install

Tell OpenCode:

```
Clone https://github.com/upsun/ai to ~/.config/opencode/upsun, then create directory ~/.config/opencode/plugins, then symlink ~/.config/opencode/upsun/.opencode/plugins/upsun.js to ~/.config/opencode/plugins/upsun.js, then symlink ~/.config/opencode/upsun/skills to ~/.config/opencode/skills/upsun, then restart opencode.
```

## Manual Installation

### Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- Git installed

### macOS / Linux

```bash
# 1. Install Upsun (or update existing)
if [ -d ~/.config/opencode/upsun ]; then
  cd ~/.config/opencode/upsun && git pull
else
  git clone https://github.com/upsun/ai.git ~/.config/opencode/upsun
fi

# 2. Create directories
mkdir -p ~/.config/opencode/plugins ~/.config/opencode/skills

# 3. Remove old symlinks/directories if they exist
rm -f ~/.config/opencode/plugins/upsun.js
rm -rf ~/.config/opencode/skills/upsun

# 4. Create symlinks
ln -s ~/.config/opencode/upsun/.opencode/plugins/upsun.js ~/.config/opencode/plugins/upsun.js
ln -s ~/.config/opencode/upsun/skills ~/.config/opencode/skills/upsun

# 5. Restart OpenCode
```

#### Verify Installation

```bash
ls -l ~/.config/opencode/plugins/upsun.js
ls -l ~/.config/opencode/skills/upsun
```

Both should show symlinks pointing to the upsun directory.

### Windows

**Prerequisites:**
- Git installed
- Either **Developer Mode** enabled OR **Administrator privileges**
  - Windows 10: Settings → Update & Security → For developers
  - Windows 11: Settings → System → For developers

#### PowerShell

Run as Administrator, or with Developer Mode enabled:

```powershell
# 1. Install Upsun
git clone https://github.com/upsun/ai.git "$env:USERPROFILE\.config\opencode\upsun"

# 2. Create directories
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\plugins"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\skills"

# 3. Remove existing links (safe for reinstalls)
Remove-Item "$env:USERPROFILE\.config\opencode\plugins\upsun.js" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.config\opencode\skills\upsun" -Force -ErrorAction SilentlyContinue

# 4. Create plugin symlink (requires Developer Mode or Admin)
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\plugins\upsun.js" -Target "$env:USERPROFILE\.config\opencode\upsun\.opencode\plugins\upsun.js"

# 5. Create skills junction (works without special privileges)
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\skills\upsun" -Target "$env:USERPROFILE\.config\opencode\upsun\skills"

# 6. Restart OpenCode
```

#### Verify Installation

```powershell
Get-ChildItem "$env:USERPROFILE\.config\opencode\plugins" | Where-Object { $_.LinkType }
Get-ChildItem "$env:USERPROFILE\.config\opencode\skills" | Where-Object { $_.LinkType }
```

## Usage

### Finding Skills

Use OpenCode's native `skill` tool to list all available skills:

```
use skill tool to list skills
```

### Loading a Skill

Use OpenCode's native `skill` tool to load the Upsun skill:

```
use skill tool to load upsun/using-upsun
```

### Personal Skills

Create your own skills in `~/.config/opencode/skills/`:

```bash
mkdir -p ~/.config/opencode/skills/my-skill
```

Create `~/.config/opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your skill content here]
```

### Project Skills

Create project-specific skills in your OpenCode project:

```bash
mkdir -p .opencode/skills/my-project-skill
```

Create `.opencode/skills/my-project-skill/SKILL.md`:

```markdown
---
name: my-project-skill
description: Use when [condition] - [what it does]
---

# My Project Skill

[Your skill content here]
```

## Skill Locations

OpenCode discovers skills from these locations:

1. **Project skills** (`.opencode/skills/`) - Highest priority
2. **Personal skills** (`~/.config/opencode/skills/`)
3. **Upsun skills** (`~/.config/opencode/skills/upsun/`) - via symlink

## Features

### Automatic Context Injection

The plugin automatically injects Upsun context via the `experimental.chat.system.transform` hook. This adds the "using-upsun" skill content to the system prompt on every request.

### Native Skills Integration

Upsun uses OpenCode's native `skill` tool for skill discovery and loading. Skills are symlinked into `~/.config/opencode/skills/upsun/` so they appear alongside your personal and project skills.

### Tool Mapping

Skills written for Claude Code are automatically adapted for OpenCode. The bootstrap provides mapping instructions:

- `TodoWrite` → `update_plan`
- `Task` with subagents → OpenCode's `@mention` system
- `Skill` tool → OpenCode's native `skill` tool
- File operations → Native OpenCode tools

## Architecture

### Plugin Structure

**Location:** `~/.config/opencode/upsun/.opencode/plugins/upsun.js`

**Components:**
- `experimental.chat.system.transform` hook for bootstrap injection
- Reads and injects the "using-upsun" skill content

### Skills

**Location:** `~/.config/opencode/skills/upsun/` (symlink to `~/.config/opencode/upsun/skills/`)

Skills are discovered by OpenCode's native skill system. Each skill has a `SKILL.md` file with YAML frontmatter.

## Updating

```bash
cd ~/.config/opencode/upsun
git pull
```

Restart OpenCode to load the updates.

## Troubleshooting

### Plugin not loading

1. Check plugin exists: `ls ~/.config/opencode/upsun/.opencode/plugins/upsun.js`
2. Check symlink/junction: `ls -l ~/.config/opencode/plugins/` (macOS/Linux) or `dir /AL %USERPROFILE%\.config\opencode\plugins` (Windows)
3. Check OpenCode logs for errors

### Skills not found

1. Verify skills symlink: `ls -l ~/.config/opencode/skills/upsun` (should point to upsun/skills/)
2. Use OpenCode's `skill` tool to list available skills
3. Check skill structure: each skill needs a `SKILL.md` file with valid frontmatter

### Bootstrap not appearing

1. Verify using-upsun skill exists: `ls ~/.config/opencode/upsun/skills/using-upsun/SKILL.md`
2. Check OpenCode version supports `experimental.chat.system.transform` hook
3. Restart OpenCode after plugin changes

## Getting Help

- Report issues: https://github.com/upsun/ai/issues
- Main documentation: https://github.com/upsun/ai
- OpenCode docs: https://opencode.ai/docs/

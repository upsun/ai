# Upsun for Codex

Guide for using Upsun with OpenAI Codex via native skill discovery.

## Quick Install

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/upsun/ai/refs/heads/main/.codex/INSTALL.md
```

## Manual Installation

### Prerequisites

- OpenAI Codex CLI
- Git

### Steps

1. Clone the repo:
   ```bash
   git clone https://github.com/upsun/ai.git ~/.codex/upsun
   ```

2. Create the skills symlink:
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/upsun/skills ~/.agents/skills/upsun
   ```

3. Restart Codex.

### Windows

Use a junction instead of a symlink (works without Developer Mode):

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\upsun" "$env:USERPROFILE\.codex\upsun\skills"
```

## How It Works

Codex has native skill discovery — it scans `~/.agents/skills/` at startup, parses SKILL.md frontmatter, and loads skills on demand. Upsun skills are made visible through a single symlink:

```
~/.agents/skills/upsun/ → ~/.codex/upsun/skills/
```

The `using-upsun` skill is discovered automatically and activates when you mention Upsun-related tasks.

## Usage

Skills are discovered automatically. Codex activates them when:

- You mention Upsun (e.g., "deploy to Upsun", "create Upsun environment")
- The task matches the skill's description (deployments, backups, environments, etc.)

### Personal Skills

Create your own skills in `~/.agents/skills/`:

```bash
mkdir -p ~/.agents/skills/my-skill
```

Create `~/.agents/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your skill content here]
```

The `description` field is how Codex decides when to activate a skill automatically — write it as a clear trigger condition.

## Updating

```bash
cd ~/.codex/upsun && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/upsun
```

**Windows (PowerShell):**
```powershell
Remove-Item "$env:USERPROFILE\.agents\skills\upsun"
```

Optionally delete the clone: `rm -rf ~/.codex/upsun` (Windows: `Remove-Item -Recurse -Force "$env:USERPROFILE\.codex\upsun"`).

## Troubleshooting

### Skills not showing up

1. Verify the symlink: `ls -la ~/.agents/skills/upsun`
2. Check skills exist: `ls ~/.codex/upsun/skills`
3. Restart Codex — skills are discovered at startup

### Windows junction issues

Junctions normally work without special permissions. If creation fails, try running PowerShell as administrator.

## Getting Help

- Report issues: https://github.com/upsun/ai/issues
- Main documentation: https://github.com/upsun/ai

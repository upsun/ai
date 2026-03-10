# Installing Upsun for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- Git installed

## Installation Steps

### 1. Clone Upsun

```bash
git clone https://github.com/upsun/ai.git ~/.config/opencode/upsun
```

### 2. Register the Plugin

Create a symlink so OpenCode discovers the plugin:

```bash
mkdir -p ~/.config/opencode/plugins
rm -f ~/.config/opencode/plugins/upsun.js
ln -s ~/.config/opencode/upsun/.opencode/plugins/upsun.js ~/.config/opencode/plugins/upsun.js
```

### 3. Symlink Skills

Create a symlink so OpenCode's native skill tool discovers Upsun skills:

```bash
mkdir -p ~/.config/opencode/skills
rm -rf ~/.config/opencode/skills/upsun
ln -s ~/.config/opencode/upsun/skills ~/.config/opencode/skills/upsun
```

### 4. Restart OpenCode

Restart OpenCode. The plugin will automatically inject Upsun context.

Verify by asking: "Can you help me deploy to Upsun?"

## Usage

### Finding Skills

Use OpenCode's native `skill` tool to list available skills:

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

Create project-specific skills in `.opencode/skills/` within your project.

**Skill Priority:** Project skills > Personal skills > Upsun skills

## Updating

```bash
cd ~/.config/opencode/upsun
git pull
```

## Troubleshooting

### Plugin not loading

1. Check plugin symlink: `ls -l ~/.config/opencode/plugins/upsun.js`
2. Check source exists: `ls ~/.config/opencode/upsun/.opencode/plugins/upsun.js`
3. Check OpenCode logs for errors

### Skills not found

1. Check skills symlink: `ls -l ~/.config/opencode/skills/upsun`
2. Verify it points to: `~/.config/opencode/upsun/skills`
3. Use `skill` tool to list what's discovered

### Tool mapping

When skills reference Claude Code tools:
- `TodoWrite` → `update_plan`
- `Task` with subagents → `@mention` syntax
- `Skill` tool → OpenCode's native `skill` tool
- File operations → your native tools

## Getting Help

- Report issues: https://github.com/upsun/ai/issues
- Full documentation: https://github.com/upsun/ai/blob/main/docs/README.opencode.md

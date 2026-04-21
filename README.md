# Upsun plugin for AI coding agents

> **⚠️ Warning:** This project is in early and active development. Things may change without notice.

Upsun plugin for AI coding agents and IDEs. Manage [Upsun](https://upsun.com) projects with skills and an MCP server. The plugin lives in `plugins/upsun/` and can be shared across multiple agents. Plugins are available for Claude Code and Cursor, with skill-based integration for other IDEs and agents via [skills.sh](https://skills.sh).

## What's included

| Component | Location | Description |
|-----------|----------|-------------|
| **Skills** | `plugins/upsun/skills/` | `upsun` – workflow guide for deployments, environments, backups, databases, and more, with a config reference |
| **MCP Server** | `plugins/upsun/.mcp.json` | Natural-language infrastructure management via [Upsun MCP](https://docs.upsun.com/get-started/ai/using-the-mcp.html) |

## Installation

### Prerequisites

1. **Upsun CLI** v5.6.0 or higher installed and authenticated
   
   ```bash
   # Install Upsun CLI (if not already installed)
   curl -fsSL https://raw.githubusercontent.com/upsun/cli/main/installer.sh | bash

   # Or via brew
   brew install upsun/tap/upsun-cli

   # Authenticate
   upsun login
   ```

2. **AI coding agent or IDE** – e.g. [Claude Code](https://claude.ai/code), Cursor, or other MCP-compatible tools

### Claude Code

```bash
# In Claude Code, run:
/plugin marketplace add upsun/ai
/plugin install upsun@upsun
/reload-plugins
```

> **Note:** A restart of Claude Code may be needed if the plugin install command fails.

### Other IDEs and AI Agents (via skills.sh)

Install the Upsun skill for Cursor, VS Code, Windsurf, and any other AI agent or IDE that supports [skills.sh](https://skills.sh):

```bash
npx skills add https://github.com/upsun/ai --skill upsun
```

After installation, the skill is immediately available to your AI agent. Ask it about Upsun tasks and it will use the skill automatically — for example: "Deploy to Upsun" or "Create a new environment."

### Alternative: Skills only (manual)

To install just the skills without the full plugin, copy the contents of `plugins/upsun/skills/` into your agent's skills directory so that the `upsun/` folder ends up directly inside it (for example, at `~/.claude/skills/upsun/` for Claude Code). This includes all current and future skills in the repo.

**Claude Code:**

```bash
git clone https://github.com/upsun/ai.git /tmp/upsun-ai
# Copy the contents of the skills directory so that ~/.claude/skills/upsun/ is created
cp -r /tmp/upsun-ai/plugins/upsun/skills/. ~/.claude/skills/
```

### Configure Permissions

#### Plugin installation (automatic)

If you installed via the plugin system, recommended permissions are automatically suggested. Accept them to enable full functionality.

#### Manual installation

Add Upsun CLI permissions to your agent's settings. For Claude Code, create or edit `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(upsun auth:*)",
      "Bash(upsun environment:*)",
      "Bash(upsun activity:*)",
      "Bash(upsun backup:*)",
      "Bash(upsun project:*)",
      "Bash(upsun logs:*)",
      "Bash(upsun resources:*)",
      "Bash(upsun metrics:*)",
      "Bash(upsun user:*)",
      "Bash(upsun organization:*)"
    ]
  }
}
```

For global permissions, edit `~/.claude/settings.json` with the same structure. For other IDEs, refer to your agent's documentation for configuring permissions.

### MCP Server (Optional)

The plugin includes the [Upsun MCP Server](https://docs.upsun.com/get-started/ai/using-the-mcp.html) for natural-language infrastructure management. The server authenticates via OAuth2 by default — run `/plugin` in Claude Code to sign in.

To use an API token instead (generated in [Upsun Console](https://console.upsun.com) → Account settings), add the `upsun-api-token` header to the MCP server config in your agent's settings.

### Verify Installation

1. Open your AI coding agent or IDE in a project
2. Ask: "Can you help me deploy to Upsun?"
3. The plugin's skill should activate and offer assistance

## Usage

The skill activates automatically when you mention Upsun-related tasks:

- "Deploy to Upsun"
- "Create a new Upsun environment"
- "Backup the production environment"
- "Check Upsun environment status"
- "Scale Upsun resources"
- "Manage Upsun users"

### Quick Start Examples

**Deploy to production:**
```
"Deploy my changes to the production environment on Upsun"
```

**Create and test a feature branch:**
```
"Create a new feature environment for testing my authentication changes"
```

**Health check:**
```
"Check the health of my production Upsun environment"
```

**Backup before changes:**
```
"Create a verified backup of production before I deploy"
```

**Resource optimization:**
```
"Audit resource usage across all my Upsun environments"
```

### Skill documentation

- **[SKILL.md](plugins/upsun/skills/upsun/SKILL.md)** – Workflow guide and common operations
- **[references/config.md](plugins/upsun/skills/upsun/references/config.md)** – `.upsun/config.yaml` reference templates

### Skill architecture

The `upsun` skill uses a progressive disclosure architecture:

1. **SKILL.md** (entry point) – Workflow navigation and common operations
2. **references/** (on-demand) – Detailed documentation loaded as needed

This design minimizes context usage.

### Plugin structure

All plugin components live inside `plugins/upsun/`. When adding new functionality, place it in the corresponding subdirectory:

```
plugins/upsun/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── .mcp.json              # MCP server configuration
└── skills/
    └── upsun/             # Upsun skill
```

This structure means the plugin is self-contained and reusable — any agent that installs `upsun@upsun` gets all components automatically.

### Adding documentation

1. Update existing reference files in `plugins/upsun/skills/upsun/references/`
2. Add cross-references to related documents
3. Update `SKILL.md` if adding commonly-used commands
4. Test that your agent can find and use the new documentation

### Requirements

- Upsun CLI v5.6.0 or higher
- AI coding agent or IDE (Claude Code, Cursor, etc.)
- Authenticated Upsun account

### License

This project is licensed under the MIT - see the [LICENSE](LICENSE) file for details.

### Support

- **Upsun Documentation**: https://docs.upsun.com
- **Upsun CLI Reference**: https://docs.upsun.com/administration/cli/reference.html
- **Claude Code** (plugin docs): https://code.claude.com/docs
- **Issues**: Please report issues on the GitHub repository

### Acknowledgments

- Upsun plugin for AI coding agents and the [Upsun](https://upsun.com) Platform-as-a-Service
- Uses Upsun CLI v5.6.0+ command structure


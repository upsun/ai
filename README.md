# Upsun plugin for AI coding agents

> **⚠️ Warning:** This project is in early and active development. Things may change without notice.

Upsun plugin for AI coding agents and IDEs. Manage [Upsun](https://upsun.com) projects with skills and MCP server. The plugin lives in `plugins/upsun/` and can be shared across multiple agents. Plugins are available for Claude Code, with support for other IDEs coming soon.

## What's included

| Component | Location | Description |
|-----------|----------|-------------|
| **Skills** | `plugins/upsun/skills/` | `using-upsun` – 130+ CLI commands for deployments, environments, backups, databases, and more |
| **MCP Server** | `plugins/upsun/.mcp.json` | Natural-language infrastructure management via [Upsun MCP](https://docs.upsun.com/get-started/ai/using-the-mcp.html) |

## Installation

### Prerequisites

1. **Upsun CLI** v5.6.0 or higher installed and authenticated
   
   ```bash
   # Install Upsun CLI (if not already installed)
   curl -fsSL https://raw.githubusercontent.com/platformsh/cli/main/installer.sh | VENDOR=upsun bash

   # Or via brew
   brew install platformsh/tap/upsun-cli

   # Authenticate
   upsun auth:browser-login
   ```

2. **AI coding agent or IDE** – e.g. [Claude Code](https://claude.ai/code), Cursor, or other MCP-compatible tools

### Claude Code

```bash
# In Claude Code, run:
/plugin marketplace add upsun/ai
/plugin install upsun@upsun
```

### OpenCode

[OpenCode](https://opencode.ai) supports skills but does not yet have a plugin marketplace, so install the skill manually.

**Global install** (available in all projects):

```bash
git clone https://github.com/upsun/ai.git /tmp/upsun-ai
cp -r /tmp/upsun-ai/plugins/upsun/skills/. ~/.agents/skills/
```

**Project-local install** (only for the current project):

```bash
git clone https://github.com/upsun/ai.git /tmp/upsun-ai
cp -r /tmp/upsun-ai/plugins/upsun/skills/. .agents/skills/
```

OpenCode will discover all skills automatically. To verify, ask your agent: "What skills do you have available?" and you should see the Upsun skills listed.

### Other IDEs

Install instructions for Cursor, VS Code, and other IDEs will be added as support is released.

### Alternative: Skills only (manual)

To install just the skills without the full plugin, copy `plugins/upsun/skills/` to your agent's skills directory. This includes all current and future skills in the repo.

**Claude Code:**

```bash
git clone https://github.com/upsun/ai.git /tmp/upsun-ai
cp -r /tmp/upsun-ai/plugins/upsun/skills/. ~/.claude/skills/
```

**OpenCode:** See the [OpenCode](#opencode) section above.

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

The plugin includes the [Upsun MCP Server](https://docs.upsun.com/get-started/ai/using-the-mcp.html) for natural-language infrastructure management. To enable it, set the `UPSUN_API_TOKEN` environment variable to your Upsun API token (generate one in [Upsun Console](https://console.upsun.com) → Account settings):

```bash
export UPSUN_API_TOKEN=your_token_here
```

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

- **[SKILL.md](plugins/upsun/skills/using-upsun/SKILL.md)** – Main skill navigation and quick reference
- **[references/](plugins/upsun/skills/using-upsun/references/)** - Detailed command documentation
  - [COMMAND-INDEX.md](plugins/upsun/skills/using-upsun/references/COMMAND-INDEX.md) - Alphabetical command reference
  - [environments.md](plugins/upsun/skills/using-upsun/references/environments.md) - Environment lifecycle
  - [deployments.md](plugins/upsun/skills/using-upsun/references/deployments.md) - Deployment patterns
  - [backups.md](plugins/upsun/skills/using-upsun/references/backups.md) - Backup/restore procedures
  - [services-databases.md](plugins/upsun/skills/using-upsun/references/services-databases.md) - Database operations
  - [resources-scaling.md](plugins/upsun/skills/using-upsun/references/resources-scaling.md) - Resource management
  - [access-security.md](plugins/upsun/skills/using-upsun/references/access-security.md) - Security and access control
  - [integration-variables.md](plugins/upsun/skills/using-upsun/references/integration-variables.md) - Configuration
  - [development-tools.md](plugins/upsun/skills/using-upsun/references/development-tools.md) - Developer tools
  - [projects-organizations.md](plugins/upsun/skills/using-upsun/references/projects-organizations.md) - Project management
  - [troubleshooting.md](plugins/upsun/skills/using-upsun/references/troubleshooting.md) - Common issues

### Skill architecture

The `using-upsun` skill uses a progressive disclosure architecture:

1. **SKILL.md** (entry point) - Workflow navigation and common operations
2. **references/** (on-demand) - Detailed documentation loaded as needed

This design minimizes context usage while providing comprehensive coverage.

### Plugin structure

All plugin components live inside `plugins/upsun/`. When adding new functionality, place it in the corresponding subdirectory:

```
plugins/upsun/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── .mcp.json              # MCP server configuration
└── skills/
    └── using-upsun/       # Upsun skill
```

This structure means the plugin is self-contained and reusable — any agent that installs `upsun@upsun` gets all components automatically.

### Adding documentation

1. Update existing reference files in `plugins/upsun/skills/using-upsun/references/`
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


# Upsun skills for AI coding agents

> **⚠️ Warning:** This project is in early and active development. Things may change without notice.

## `using-upsun`

A comprehensive AI Coding Agent Skill for managing [Upsun](https://upsun.com) projects using the Upsun CLI.

### Overview

This skill enables your agent to help you manage Upsun projects through the Upsun CLI (v5.6.0+), covering:

- **130+ CLI commands** across 30 namespaces
- **Deployment workflows** with safe production deployment patterns
- **Environment management** including branching, merging, and synchronization
- **Backup and restore** operations with verification and safety checks
- **Resource scaling** and autoscaling configuration
- **Database operations** for PostgreSQL, MongoDB, Redis, and Valkey
- **Security and access** management for teams and users
- **Development tools** including SSH, tunnels, and log access

### Installation

#### Prerequisites

1. **Upsun CLI** v5.6.0 or higher installed and authenticated
   
   ```bash
   # Install Upsun CLI (if not already installed)
   curl -fsSL https://raw.githubusercontent.com/platformsh/cli/main/installer.sh | VENDOR=upsun bash

   # Or via brew
   brew install platformsh/tap/upsun-cli

   # Authenticate
   upsun auth:browser-login
   ```

2. **Claude Code** - Available at [claude.ai/code](https://claude.ai/code) or any other AI coding agent

#### Option 1: Plugin Installation (Recommended for Claude)

Install via Claude Code plugin system:

```bash
# In Claude Code, run:
/plugin marketplace add upsun/ai
/plugin install upsun@upsun
```

The plugin will automatically:
- Install the skill and all helper scripts
- Set up recommended permissions
- Make the skill available across all your projects

#### Option 2: Personal Skills Directory

Install for all your projects manually:

```bash
# Clone to personal skills directory
mkdir -p ~/.claude/skills
cd ~/.claude/skills
git clone https://github.com/upsun/skills.git upsun

# Or download and extract
curl -L https://github.com/upsun/skills/archive/main.zip -o upsun.zip
unzip upsun.zip -d ~/<AGENT_CONFIG_FOLDER>/skills/

# Move files to the coding agent folder

mv using-upsun ~/<AGENT_CONFIG_FOLDER>/skills/upsun
```

### Configure Permissions

#### Plugin Installation (Automatic)

If you installed via `/plugin install`, recommended permissions are automatically suggested. Accept them to enable full functionality.

#### Manual Installation

Add Upsun CLI permissions to your Claude Code settings:

**For project-specific permissions**, create or edit `.claude/settings.local.json`:

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

**For global permissions**, edit `~/.claude/settings.json` with the same structure.

> Please refer to your specific agent documentation for configuring permissions.

### MCP Server (Optional)

The plugin includes the [Upsun MCP Server](https://docs.upsun.com/get-started/ai/using-the-mcp.html) for natural-language infrastructure management. To enable it, set the `UPSUN_API_TOKEN` environment variable to your Upsun API token (generate one in [Upsun Console](https://console.upsun.com) → Account settings):

```bash
export UPSUN_API_TOKEN=your_token_here
```

### Verify Installation

1. Open your AI coding agent in a project or terminal
2. Ask it: "Can you help me deploy to Upsun?"
3. It should activate the Upsun skill and offer assistance

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

### Documentation

- **[SKILL.md](skills/using-upsun/SKILL.md)** - Main skill navigation and quick reference
- **[references/](skills/using-upsun/references/)** - Detailed command documentation
  - [COMMAND-INDEX.md](skills/using-upsun/references/COMMAND-INDEX.md) - Alphabetical command reference
  - [environments.md](skills/using-upsun/references/environments.md) - Environment lifecycle
  - [deployments.md](skills/using-upsun/references/deployments.md) - Deployment patterns
  - [backups.md](skills/using-upsun/references/backups.md) - Backup/restore procedures
  - [services-databases.md](skills/using-upsun/references/services-databases.md) - Database operations
  - [resources-scaling.md](skills/using-upsun/references/resources-scaling.md) - Resource management
  - [access-security.md](skills/using-upsun/references/access-security.md) - Security and access control
  - [integration-variables.md](skills/using-upsun/references/integration-variables.md) - Configuration
  - [development-tools.md](skills/using-upsun/references/development-tools.md) - Developer tools
  - [projects-organizations.md](skills/using-upsun/references/projects-organizations.md) - Project management
  - [troubleshooting.md](skills/using-upsun/references/troubleshooting.md) - Common issues

### Architecture

This skill uses a progressive disclosure architecture:

1. **SKILL.md** (entry point) - Workflow navigation and common operations
2. **references/** (on-demand) - Detailed documentation loaded as needed

This design minimizes context usage while providing comprehensive coverage.

### Adding Documentation

1. Update existing reference files in `references/`
2. Add cross-references to related documents
3. Update `SKILL.md` if adding commonly-used commands
4. Test that Claude can find and use the new documentation

### Requirements

- Upsun CLI v5.6.0 or higher
- Claude Code (CLI or IDE extension)
- Authenticated Upsun account

### License

This project is licensed under the MIT - see the [LICENSE](LICENSE) file for details.

### Support

- **Upsun Documentation**: https://docs.upsun.com
- **Upsun CLI Reference**: https://docs.upsun.com/administration/cli/reference.html
- **Claude Code Documentation**: https://code.claude.com/docs
- **Issues**: Please report issues on the GitHub repository

### Acknowledgments

- Built for the [Upsun](https://upsun.com) Platform-as-a-Service
- Utilizes Upsun CLI v5.6.0 command structure


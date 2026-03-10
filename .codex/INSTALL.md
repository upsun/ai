# Installing Upsun for Codex

Enable Upsun skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the Upsun repository:**
   ```bash
   git clone https://github.com/upsun/ai.git ~/.codex/upsun
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/upsun/skills ~/.agents/skills/upsun
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\upsun" "$env:USERPROFILE\.codex\upsun\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Migrating from old bootstrap

If you installed Upsun before native skill discovery, you need to:

1. **Update the repo:**
   ```bash
   cd ~/.codex/upsun && git pull
   ```

2. **Create the skills symlink** (step 2 above) — this is the new discovery mechanism.

3. **Remove the old bootstrap block** from `~/.codex/AGENTS.md` — any block referencing `upsun-codex bootstrap` is no longer needed.

4. **Restart Codex.**

## Verify

```bash
ls -la ~/.agents/skills/upsun
```

You should see a symlink (or junction on Windows) pointing to your Upsun skills directory.

## Updating

```bash
cd ~/.codex/upsun && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/upsun
```

Optionally delete the clone: `rm -rf ~/.codex/upsun`.

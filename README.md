# Debian Tool Kit

Master launcher for all Debian tools — browse descriptions and run interactively.

## Quick Start

```bash
su -
bash <(curl -fsSL https://raw.githubusercontent.com/alsosram/deb-toolkit/master/install.sh)
```

## Available Tools

| # | Tool | Description |
|---|------|-------------|
| 1 | deb-auto     | Debian setup (sudo, curl, cockpit, SSH) |
| 2 | deb-bootopti | Boot speed optimizer (trim initramfs, GRUB, services) |
| 3 | deb-autorr   | Full auto rr stack — install, OMV layout, claim, purge, fix perms |
| 4 | deb-crafty   | Minecraft Server (Crafty Controller) — web-based server manager |

## Options

```bash
# Show available tools without running
bash install.sh --list

# Run a specific tool by number
bash install.sh 2

# Interactive menu (default)
bash install.sh
```

## Adding a New Tool

The toolbox is defined by [`tools.json`](tools.json). To add a new tool, edit that file:

```json
{
  "name": "my-tool",
  "desc": "What it does",
  "url": "my-tool/main/install.sh"
}
```

The `url` is relative to `https://raw.githubusercontent.com/alsosram/`. That's it — `install.sh` reads the manifest dynamically, no script changes needed.

# Debian Tool Kit

Master launcher for all Debian tools — browse descriptions and run interactively.

## Quick Start

```bash
su -
bash <(curl -fsSL https://raw.githubusercontent.com/alsosram/deb-toolkit/master/install.sh)
```

## Tools Included

| # | Tool | Description |
|---|------|-------------|
| 1 | **deb-auto** | Debian setup (sudo, curl, cockpit, SSH) |
| 2 | **deb-bootopti** | Boot speed optimizer (trim initramfs, GRUB, services) |
| 3 | **deb-autorr** | Movie automation stack (Radarr, Prowlarr, qBittorrent, Plex/Jellyfin) |

## Options

```bash
# Show available tools without running
bash install.sh --list

# Run a specific tool by number
bash install.sh 2

# Interactive menu (default)
bash install.sh
```

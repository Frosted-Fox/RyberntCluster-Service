# Rybernt Cluster

Rybernt Cluster helps you manage encrypted backups for your Linux servers,
with a simple setup and dashboard for backups and restores.

## Requirements

- Debian or Ubuntu on `amd64`
- `curl` and `sha256sum` (available by default on most Debian/Ubuntu systems)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Frosted-Fox/RyberntCluster-Service/main/install-remote.sh \
  -o install-remote.sh
sudo sh install-remote.sh
```

The installer downloads the latest public GitHub release directly and verifies
the package using its published SHA-256 checksum. GitHub CLI authentication is
not required.

On systems with systemd, setup enables the scheduled backup service.
Containers without systemd can complete setup, but scheduled backups will not
run automatically; use a systemd host for unattended backups.

For one-time token enrollment, you can pass the token during installation:

```sh
sudo sh install-remote.sh --token "$TOKEN"
```

The token is exposed in shell history and process arguments when using this
option. The default masked prompt is safer.

Follow the on-screen instructions to finish setup.

## Open Rybernt Cluster

```sh
sudo rybernt backup
```

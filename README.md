# Rybernt Cluster Backup

Rybernt Cluster is a Linux backup client for servers. It uses Restic for
encrypted, deduplicated backups and connects to the Rybernt Backup API; backup
nodes do not receive S3 credentials.

This private repository contains the installer and release documentation.
The application is distributed as a Nuitka-compiled Debian package; the
Python source and API/server files are not included here.

## Requirements

- Debian or Ubuntu, `amd64`
- A running `systemd` installation
- Access to the private GitHub repository and its releases
- GitHub CLI (`gh`), authenticated with an account that has repository access

## Install

Install GitHub CLI from its official instructions, then authenticate and clone
this repository:

```sh
gh auth login --hostname github.com
gh repo clone Frosted-Fox/RyberntCluster-Service
cd RyberntCluster-Service
sudo sh install-remote.sh
```

The installer downloads the latest compiled package and its SHA-256 manifest
from the private GitHub Release, verifies the package checksum, installs it,
and launches interactive setup. The package installs `restic` and `systemd`
integration through Debian package dependencies.

If the Backup API is remote, pass its HTTPS URL to setup:

```sh
sudo env RNB_API_BASE_URL=https://backup.example.com sh install-remote.sh
```

Setup prompts for a one-time enrollment token without echoing it. Select the
node's local backup source directory; API-managed settings cannot expand
outside that local source boundary. After enrollment, the API issues a
revocable node credential. Keep the account key and enrollment tokens private.

## Use

```sh
sudo rybernt backup
sudo systemctl status rybernt-backup
sudo journalctl -u rybernt-backup -n 100 --no-pager
```

The dashboard supports backups, snapshot browsing, verification, and restores.
Restic encrypts backup data before upload. The package is compiled to make
casual source inspection harder, but compilation is not a security boundary
and does not prevent reverse engineering.

Private releases require GitHub authorization. Checksums detect incomplete or
corrupted downloads; they are not a substitute for trusting the repository
and release publisher.

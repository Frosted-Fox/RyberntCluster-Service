# Rybernt Cluster

Rybernt Cluster helps you manage encrypted backups for your Linux servers,
with a simple setup and dashboard for backups and restores.

## Requirements

- Debian or Ubuntu on `amd64`
- GitHub CLI (`gh`) signed in with access to the private Rybernt Cluster release

## Install

```sh
gh auth login --hostname github.com
gh repo clone Frosted-Fox/RyberntCluster-Service
cd RyberntCluster-Service
sudo sh install-remote.sh
```

Follow the on-screen instructions to finish setup.

## Open Rybernt Cluster

```sh
sudo rybernt backup
```

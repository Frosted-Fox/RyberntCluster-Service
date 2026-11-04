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

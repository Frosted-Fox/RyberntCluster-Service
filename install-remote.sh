#!/bin/sh
set -eu

REPOSITORY=Frosted-Fox/RyberntCluster-Service
PACKAGE=rybernt-backup_amd64.deb

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer as root: sudo sh install-remote.sh" >&2
    exit 1
fi

if [ ! -r /dev/tty ]; then
    echo "Interactive setup needs a terminal. Run this installer from a terminal." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1 ||
   ! command -v sha256sum >/dev/null 2>&1 ||
   ! command -v gh >/dev/null 2>&1; then
    echo "curl, sha256sum, and GitHub CLI (gh) are required for the private release." >&2
    echo "Authenticate with: gh auth login --hostname github.com" >&2
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1 ||
   ! command -v dpkg >/dev/null 2>&1 ||
   [ "$(dpkg --print-architecture)" != amd64 ]; then
    echo "The packaged release currently supports Debian/Ubuntu on amd64 only." >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d /tmp/rybernt-backup.XXXXXX)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

echo "Downloading the latest Rybernt Cluster release..."
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
    if ! GH_TOKEN=$(sudo -u "$SUDO_USER" gh auth token --hostname github.com); then
        echo "No GitHub CLI login found for $SUDO_USER. Run gh auth login before installing." >&2
        exit 1
    fi
    export GH_TOKEN
    gh release download --repo "$REPOSITORY" --pattern "$PACKAGE" \
        --pattern SHA256SUMS --dir "$TEMP_DIR"
    unset GH_TOKEN
else
    gh release download --repo "$REPOSITORY" --pattern "$PACKAGE" \
        --pattern SHA256SUMS --dir "$TEMP_DIR"
fi
(
    cd "$TEMP_DIR"
    sha256sum --check --ignore-missing SHA256SUMS
)

echo "Installing the Debian package downloaded over HTTPS..."
apt-get update
apt-get install -y "$TEMP_DIR/$PACKAGE"

if [ ! -x /usr/lib/rybernt/setup.sh ]; then
    echo "The installed release does not contain the interactive setup program." >&2
    exit 1
fi

exec /usr/lib/rybernt/setup.sh </dev/tty

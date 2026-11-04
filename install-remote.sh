#!/bin/sh
set -eu

REPOSITORY=Frosted-Fox/RyberntCluster-Service
PACKAGE=rybernt-backup_amd64.deb
ENROLLMENT_TOKEN=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --token)
            if [ "$#" -lt 2 ] || [ -z "$2" ] || [ -n "$ENROLLMENT_TOKEN" ]; then
                echo "Usage: sudo sh install-remote.sh [--token ONE_TIME_TOKEN]" >&2
                exit 2
            fi
            ENROLLMENT_TOKEN=$2
            shift 2
            ;;
        --help|-h)
            echo "Usage: sudo sh install-remote.sh [--token ONE_TIME_TOKEN]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: sudo sh install-remote.sh [--token ONE_TIME_TOKEN]" >&2
            exit 2
            ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo "Run Rybernt Cluster setup as root: sudo sh install-remote.sh" >&2
    exit 1
fi

if [ ! -r /dev/tty ]; then
    echo "Rybernt Cluster setup needs an interactive terminal." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1 ||
   ! command -v sha256sum >/dev/null 2>&1 ||
   ! command -v gh >/dev/null 2>&1; then
    echo "Rybernt Cluster setup requires curl, sha256sum, and GitHub CLI (gh)." >&2
    echo "Sign in with: gh auth login --hostname github.com" >&2
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1 ||
   ! command -v dpkg >/dev/null 2>&1 ||
   [ "$(dpkg --print-architecture)" != amd64 ]; then
    echo "Rybernt Cluster currently supports Debian/Ubuntu on amd64." >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d /tmp/rybernt-cluster.XXXXXX)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

echo "Downloading the latest Rybernt Cluster release..."
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
    if ! GH_TOKEN=$(sudo -u "$SUDO_USER" gh auth token --hostname github.com); then
        echo "Rybernt Cluster release access is not configured for $SUDO_USER." >&2
        echo "Sign in with: gh auth login --hostname github.com" >&2
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

echo "Installing Rybernt Cluster..."
apt-get update
echo "Installing backup requirements..."
if ! apt-get install -y restic; then
    echo "Could not install the required Restic package." >&2
    echo "On Ubuntu, make sure the Universe repository is enabled, then rerun this installer." >&2
    exit 1
fi

apt-get install -y "$TEMP_DIR/$PACKAGE"

if [ ! -x /usr/lib/rybernt/setup.sh ]; then
    echo "Rybernt Cluster setup could not be started." >&2
    exit 1
fi

if [ -n "$ENROLLMENT_TOKEN" ]; then
    RNB_ENROLLMENT_TOKEN=$ENROLLMENT_TOKEN /usr/lib/rybernt/setup.sh </dev/tty
else
    /usr/lib/rybernt/setup.sh </dev/tty
fi

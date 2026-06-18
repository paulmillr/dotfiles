#!/bin/sh
set -eu

PATH='/usr/sbin:/usr/bin:/sbin:/bin'
export PATH

script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)
source_file="$script_dir/linux-startup.sh"
dest_file="/etc/update-motd.d/50-sysinfo"
uname_file="/etc/update-motd.d/10-uname"

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    if ! command -v sudo >/dev/null 2>&1; then
      echo "This installer needs root privileges. Re-run as root or install sudo." >&2
      exit 1
    fi
    sudo "$@"
  fi
}

install_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get is unavailable; skipping optional package installation." >&2
    return
  fi

  as_root apt-get update
  as_root apt-get install -y figlet lolcat
}

case "${1:-}" in
  -h|--help)
    echo "Usage: $0 [--install-packages]"
    exit 0
    ;;
  ""|--install-packages)
    ;;
  *)
    echo "Usage: $0 [--install-packages]" >&2
    exit 2
    ;;
esac

if [ "$(uname -s)" != "Linux" ]; then
  echo "This installer is only intended for Linux systems." >&2
  exit 1
fi

if [ "${1:-}" = "--install-packages" ]; then
  install_packages
fi

if [ ! -f "$source_file" ]; then
  echo "Missing source script: $source_file" >&2
  exit 1
fi

if [ ! -d /etc/update-motd.d ]; then
  echo "Missing /etc/update-motd.d; this system does not appear to use update-motd." >&2
  exit 1
fi

as_root install -m 0755 "$source_file" "$dest_file"
as_root truncate -s 0 /etc/motd

if [ -e "$uname_file" ]; then
  as_root chmod -x "$uname_file"
fi

echo "Installed $source_file to $dest_file"
echo "Optional packages for nicer output: figlet lolcat"
echo "Temperature output also uses landscape-sysinfo when it is available."

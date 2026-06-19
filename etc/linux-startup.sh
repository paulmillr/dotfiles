#!/bin/bash

# A script that would run with terminal startup on Linux machines
# Displays resource usage, etc.
#
# apt install figlet lolcat
# chmod +x linux-startup.sh
# install -m 0755 linux-startup.sh /etc/update-motd.d/50-sysinfo
# truncate -s 0 /etc/motd && chmod -x /etc/update-motd.d/10-uname

export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/sbin:/usr/local/bin"
export LC_ALL=C
umask 077
IFS=$' \t\n'

W=$'\e[0;39m'
G=$'\e[1;32m'

# usage bar config
max_usage=90
bar_width=50
min_disk_bytes=2000000000
full_disk_usage=95

# colors
white=$'\e[39m'
green=$'\e[1;32m'
red=$'\e[1;31m'
dim=$'\e[2m'
undim=$'\e[0m'

sanitize_text() {
    printf "%s" "$1" | LC_ALL=C command tr -d '[:cntrl:]'
}

have_command() {
    type -P -- "$1" >/dev/null 2>&1
}

trusted_command_path() {
    local command_name="$1"
    local path owner mode group_digit other_digit

    path=$(type -P -- "$command_name" 2>/dev/null) || return 1
    [ -n "$path" ] && [ -x "$path" ] || return 1

    case "$path" in
        /bin/*|/usr/bin/*|/sbin/*|/usr/sbin/*|/usr/games/*|/usr/local/bin/*|/usr/local/sbin/*) ;;
        *) return 1 ;;
    esac

    if ! IFS=" " read -r owner mode < <(command stat -Lc '%u %a' -- "$path" 2>/dev/null); then
        return 1
    fi

    [ "$owner" = "0" ] || return 1

    group_digit=${mode: -2:1}
    other_digit=${mode: -1}
    [[ ! "$group_digit" =~ [2367] ]] && [[ ! "$other_digit" =~ [2367] ]] || return 1

    printf "%s" "$path"
}

print_usage_bar() {
    local usage="$1"

    if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
        usage=0
    elif [ "$usage" -gt 100 ]; then
        usage=100
    fi

    local used_width=$(((usage * bar_width) / 100))
    local color="$green"
    if [ "$usage" -ge "$max_usage" ]; then
        color=$red
    fi

    local bar="[${color}"
    local i
    for ((i = 0; i < used_width; i++)); do
        bar+="="
    done

    bar+="${white}${dim}"
    for ((i = used_width; i < bar_width; i++)); do
        bar+="="
    done

    bar+="${undim}]"
    printf "%s\n" "$bar"
}

print_usage_line() {
    local label="$1"
    local used="$2"
    local total="$3"
    local usage="$4"

    label=$(sanitize_text "$label")
    used=$(sanitize_text "$used")
    total=$(sanitize_text "$total")

    printf "  %-31s%s out of %s\n" "$label" "$used" "$total"
    printf "  "
    print_usage_bar "$usage"
}

format_bytes_decimal() {
    local bytes="$1"

    command awk -v bytes="$bytes" 'BEGIN {
        if (bytes >= 1000000000000) {
            printf "%.0f Tb", bytes / 1000000000000
        } else if (bytes >= 1000000000) {
            printf "%.0f Gb", bytes / 1000000000
        } else if (bytes >= 1000000) {
            printf "%.0f Mb", bytes / 1000000
        } else if (bytes >= 1000) {
            printf "%.0f Kb", bytes / 1000
        } else {
            printf "%d B", bytes
        }
    }'
}

format_network_bytes() {
    local bytes="$1"

    command awk -v bytes="$bytes" 'BEGIN {
        if (bytes >= 1000000000000) {
            value = bytes / 1000000000000
            unit = "Tb"
        } else if (bytes >= 1000000000) {
            value = bytes / 1000000000
            unit = "Gb"
        } else if (bytes >= 1000000) {
            value = bytes / 1000000
            unit = "Mb"
        } else if (bytes >= 1000) {
            value = bytes / 1000
            unit = "Kb"
        } else {
            printf "%d B", bytes
            exit
        }

        text = sprintf("%.1f%s", value, unit)
        sub(/\.0/, "", text)
        printf "%s", text
    }'
}

format_bytes_gib() {
    local bytes="$1"

    command awk -v bytes="$bytes" 'BEGIN {
        printf "%.0f Gb", bytes / 1073741824
    }'
}

get_service_status() {
    if ! have_command systemctl; then
        printf "OK"
        return
    fi

    local failed_units
    failed_units=$(command systemctl --failed --type=service --no-legend --plain --no-pager 2>/dev/null)

    local failed_count
    failed_count=$(command awk '
        {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /\.service$/) {
                    count++
                    next
                }
            }
        }
        END {
            print count + 0
        }
    ' <<<"$failed_units")
    if [ "$failed_count" -eq 0 ]; then
        printf "OK"
    else
        printf "%s failed" "$failed_count"
    fi
}

get_login_counts() {
    if ! have_command who; then
        printf "0 active, 0 remote"
        return
    fi

    command who | command awk '
        NF {
            active++
            if ($NF ~ /^\(/ && $NF !~ /^\(:/) {
                remote++
            }
        }
        END {
            printf "%d active, %d remote", active + 0, remote + 0
        }
    '
}

get_network_traffic() {
    local rx_total=0
    local tx_total=0
    local found=0
    local rx_file tx_file iface rx_bytes tx_bytes totals

    for rx_file in /sys/class/net/*/statistics/rx_bytes; do
        [ -e "$rx_file" ] || continue

        iface=${rx_file#/sys/class/net/}
        iface=${iface%%/*}
        [ "$iface" = "lo" ] && continue

        tx_file="/sys/class/net/$iface/statistics/tx_bytes"
        [ -r "$rx_file" ] || continue
        [ -r "$tx_file" ] || continue

        if ! read -r rx_bytes <"$rx_file"; then
            rx_bytes=0
        fi
        if ! read -r tx_bytes <"$tx_file"; then
            tx_bytes=0
        fi

        [[ "$rx_bytes" =~ ^[0-9]+$ ]] || rx_bytes=0
        [[ "$tx_bytes" =~ ^[0-9]+$ ]] || tx_bytes=0

        rx_total=$((rx_total + rx_bytes))
        tx_total=$((tx_total + tx_bytes))
        found=1
    done

    if [ "$found" -eq 0 ] && [ -r /proc/net/dev ]; then
        totals=$(command awk -F'[: ]+' '
            NR > 2 {
                iface = $2
                if (iface != "lo" && $3 ~ /^[0-9]+$/ && $11 ~ /^[0-9]+$/) {
                    rx += $3
                    tx += $11
                    found = 1
                }
            }
            END {
                if (found) {
                    printf "%.0f %.0f", rx, tx
                }
            }
        ' /proc/net/dev 2>/dev/null)

        if IFS=" " read -r rx_total tx_total <<<"$totals"; then
            if [[ "$rx_total" =~ ^[0-9]+$ ]] && [[ "$tx_total" =~ ^[0-9]+$ ]]; then
                found=1
            fi
        fi
    fi

    if [ "$found" -eq 0 ]; then
        printf "n/a"
        return
    fi

    printf "%s in, %s out" "$(format_network_bytes "$rx_total")" "$(format_network_bytes "$tx_total")"
}

get_top_process() {
    local sort_key="$1"
    local top_process
    local self_pid="$$"
    local shell_pid="${BASHPID:-$$}"

    case "$sort_key" in
        pcpu|pmem) ;;
        *)
            printf "n/a"
            return
            ;;
    esac

    top_process=$(command ps -eo pid=,ppid=,user=,"$sort_key"=,comm= --sort=-"$sort_key" 2>/dev/null | command awk -v red="$red" -v reset="$W" -v self_pid="$self_pid" -v shell_pid="$shell_pid" '
        NF >= 5 {
            pid = $1
            ppid = $2
            user = $3
            usage = $4 + 0
            command_name = $5

            if (pid == self_pid || pid == shell_pid || ppid == self_pid || ppid == shell_pid) {
                next
            }
            if (command_name == "ps" || command_name == "awk") {
                next
            }

            gsub(/[[:cntrl:]]/, "", user)
            gsub(/[[:cntrl:]]/, "", command_name)
            if (usage > 0 && usage < 1) {
                usage_text = sprintf("%.1f%%", usage)
            } else {
                usage_text = sprintf("%.0f%%", usage)
            }
            text = sprintf("%s %s (by %s)", usage_text, command_name, user)
            if (usage > 50) {
                printf "%s%s%s", red, text, reset
            } else {
                printf "%s", text
            }
            exit
        }
    ')

    if [ -n "$top_process" ]; then
        printf "%s" "$top_process"
    else
        printf "n/a"
    fi
}

get_temperature() {
    local landscape temp

    landscape=$(trusted_command_path landscape-sysinfo) || return
    if [ -z "$landscape" ]; then
        return
    fi

    temp=$("$landscape" --sysinfo-plugins Temperature 2>/dev/null \
        | command sed 's/ *$//g' \
        | command sed 's/^ *//g' \
        | command sed 's/^Temperature: *//g' \
        | command awk 'NF {print; exit}')
    sanitize_text "$temp"
}

load_color() {
    local load="$1"
    local processor_count="$2"

    if command awk -v load="$load" -v processor_count="$processor_count" 'BEGIN {
        if (processor_count !~ /^[0-9]+$/ || processor_count < 1) {
            processor_count = 1
        }
        exit !(load > processor_count)
    }'; then
        printf "%s" "$red"
    else
        printf "%s" "$W"
    fi
}

format_load_percent() {
    local load="$1"
    local processor_count="$2"

    command awk -v load="$load" -v processor_count="$processor_count" 'BEGIN {
        if (processor_count !~ /^[0-9]+$/ || processor_count < 1) {
            processor_count = 1
        }
        printf "%.0f%%", (load / processor_count) * 100
    }'
}

get_hostname() {
    local value

    value=$(command hostname 2>/dev/null)
    if [ -z "$value" ]; then
        value="unknown"
    fi

    sanitize_text "$value"
}

get_os_pretty_name() {
    local value

    value=$(command awk -F= '
        $1 == "PRETTY_NAME" {
            value = substr($0, index($0, "=") + 1)
            gsub(/^"/, "", value)
            gsub(/"$/, "", value)
            print value
            exit
        }
    ' /etc/os-release 2>/dev/null)

    value=$(sanitize_text "$value")
    if [ -n "$value" ]; then
        printf "%s" "$value"
    else
        printf "unknown"
    fi
}

get_kernel() {
    local value

    value=$(command uname -sr 2>/dev/null)
    value=$(sanitize_text "$value")
    if [ -n "$value" ]; then
        printf "%s" "$value"
    else
        printf "unknown"
    fi
}

get_uptime() {
    local uptime_raw uptime_seconds days hours minutes

    if ! read -r uptime_raw _ </proc/uptime; then
        printf "unknown"
        return
    fi

    uptime_seconds=${uptime_raw%%.*}
    if ! [[ "$uptime_seconds" =~ ^[0-9]+$ ]]; then
        printf "unknown"
        return
    fi

    days=$((uptime_seconds / 86400))
    hours=$(((uptime_seconds % 86400) / 3600))
    minutes=$(((uptime_seconds % 3600) / 60))

    if [ "$days" -gt 0 ]; then
        printf "%dd %dh" "$days" "$hours"
    elif [ "$hours" -gt 0 ]; then
        printf "%dh %dm" "$hours" "$minutes"
    else
        printf "%dm" "$minutes"
    fi
}

### Hostname
###########################################################
HOSTNAME=$(get_hostname)
FIGLET=$(trusted_command_path figlet || true)
LOLCAT=$(trusted_command_path lolcat || true)

if [ -n "$FIGLET" ]; then
  if [ -n "$LOLCAT" ]; then
    "$FIGLET" "$HOSTNAME" | "$LOLCAT" -f
  else
    "$FIGLET" "$HOSTNAME"
  fi
else
  printf "%s\n" "$HOSTNAME"
fi

### System info
###########################################################
if ! read -r LOAD1 LOAD5 LOAD15 _ </proc/loadavg; then
    LOAD1=0
    LOAD5=0
    LOAD15=0
fi

DISTRO=$(get_os_pretty_name)
KERNEL=$(get_kernel)
UPTIME=$(get_uptime)
UPTIME=$(sanitize_text "$UPTIME")
if [ -z "$UPTIME" ]; then
    UPTIME="unknown"
fi

PROCESSOR_NAME=$(command awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)
PROCESSOR_NAME=$(sanitize_text "$PROCESSOR_NAME")
if [ -z "$PROCESSOR_NAME" ]; then
    PROCESSOR_NAME="unknown"
fi

PROCESSOR_COUNT=$(command nproc 2>/dev/null)
if ! [[ "$PROCESSOR_COUNT" =~ ^[0-9]+$ ]]; then
    PROCESSOR_COUNT=$(command awk -F: '/^processor[[:space:]]*:/ {count++} END {print count + 0}' /proc/cpuinfo)
fi
if ! [[ "$PROCESSOR_COUNT" =~ ^[0-9]+$ ]]; then
    PROCESSOR_COUNT="unknown"
fi

if ! IFS=" " read -r RAM_USAGE RAM_USED_BYTES RAM_TOTAL_BYTES < <(command free -b | command awk '
    /^Mem:/ {
        pct = int(($3 / $2) * 100 + 0.5)
        print pct, $3, $2
    }
'); then
    RAM_USAGE=0
    RAM_USED_BYTES=0
    RAM_TOTAL_BYTES=0
fi
RAM_USED=$(format_bytes_gib "$RAM_USED_BYTES")
RAM_TOTAL=$(format_bytes_gib "$RAM_TOTAL_BYTES")

SERVICES=$(get_service_status)
LOGINS=$(get_login_counts)
NETWORK_TRAFFIC=$(get_network_traffic)
CPU_EATER=$(get_top_process "pcpu")
RAM_EATER=$(get_top_process "pmem")

temp=$(get_temperature)
temp_lc=$(printf "%s" "$temp" | command tr '[:upper:]' '[:lower:]')
case "$temp_lc" in
    ""|unknown|n/a|na|none|unavailable|not\ available*|not\ supported*)
        temp=""
        ;;
esac

LOAD1_COLOR=$(load_color "$LOAD1" "$PROCESSOR_COUNT")
LOAD5_COLOR=$(load_color "$LOAD5" "$PROCESSOR_COUNT")
LOAD15_COLOR=$(load_color "$LOAD15" "$PROCESSOR_COUNT")
LOAD1_PERCENT=$(format_load_percent "$LOAD1" "$PROCESSOR_COUNT")
LOAD5_PERCENT=$(format_load_percent "$LOAD5" "$PROCESSOR_COUNT")
LOAD15_PERCENT=$(format_load_percent "$LOAD15" "$PROCESSOR_COUNT")

SERVICES_COLOR="$W"
if [ "$SERVICES" != "OK" ]; then
    SERVICES_COLOR="$red"
fi

LOGINS_COLOR="$W"
LOGINS_ACTIVE=${LOGINS%% *}
if [[ "$LOGINS_ACTIVE" =~ ^[0-9]+$ ]] && [ "$LOGINS_ACTIVE" -gt 2 ]; then
    LOGINS_COLOR="$red"
fi

printf "\n%ssystem info:%s\n" "$W" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Distro" "$W" "$DISTRO" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Kernel" "$W" "$KERNEL" "$W"
printf "%s  %-11s : %s%s (%s vCPU)%s\n" "$W" "CPU" "$W" "$PROCESSOR_NAME" "$PROCESSOR_COUNT" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "CPU eater" "$W" "$CPU_EATER" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "RAM eater" "$W" "$RAM_EATER" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Logins" "$LOGINS_COLOR" "$LOGINS" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Uptime" "$W" "$UPTIME" "$W"
printf "%s  %-11s : %s%s%s, %s%s%s, %s%s%s (1m, 5m, 15m)\n" "$W" "Load" "$LOAD1_COLOR" "$LOAD1_PERCENT" "$W" "$LOAD5_COLOR" "$LOAD5_PERCENT" "$W" "$LOAD15_COLOR" "$LOAD15_PERCENT" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Traffic" "$W" "$NETWORK_TRAFFIC" "$W"
printf "%s  %-11s : %s%s%s\n" "$W" "Services" "$SERVICES_COLOR" "$SERVICES" "$W"

if [ -n "$temp" ]; then
  printf "%s  %-11s : %s%s%s\n" "$W" "Temperature" "$G" "$temp" "$W"
fi

### Usage
###########################################################
printf "\nusage:\n"
print_usage_line "RAM" "$RAM_USED" "$RAM_TOTAL" "$RAM_USAGE"

# disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(command df -B1 -x zfs -x squashfs -x tmpfs -x devtmpfs -x overlay --output=pcent,used,size,target | command awk 'NR > 1')

for line in "${dfs[@]}"; do
    read -r percent used_bytes total_bytes target <<<"$line"
    usage=${percent%%%}
    if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
        continue
    fi
    if ! [[ "$used_bytes" =~ ^[0-9]+$ ]] || ! [[ "$total_bytes" =~ ^[0-9]+$ ]]; then
        continue
    fi

    if [ "$total_bytes" -lt "$min_disk_bytes" ] && [ "$usage" -lt "$full_disk_usage" ]; then
        continue
    fi

    used=$(format_bytes_decimal "$used_bytes")
    total=$(format_bytes_decimal "$total_bytes")
    print_usage_line "$target" "$used" "$total" "$usage"
done

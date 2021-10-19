#!/bin/bash

# A script that would run with terminal startup on debian machines
# Displays resource usage, etc.
#
# apt install figlet lolcat
# chmod +x deb-startup
# mv dev-startup /etc/update-motd.d/50-sysinfo
# truncate -s 0 /etc/motd && rm /etc/update-motd.d/10-uname

### Hostname
###########################################################
if [ -x "$(command -v figlet)" ]; then
  if [ -x "$(command -v lolcat)" ]; then
    figlet $(hostname) | lolcat -f
  else
    figlet $(hostname)
  fi
else
  echo "$(hostname)"
fi

### System info
###########################################################
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(cat /proc/loadavg | awk '{ print $1,$2,$3 }')
# get free memory
IFS=" " read USED AVAIL TOTAL <<<$(free -htm | grep "Mem" | awk {'print $3,$7,$2'})
# get processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
PROCESS_ALL=`echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
PROCESS_ROOT=`echo "$PROCESS"| grep root | awk {'print $2'}`
PROCESS_USER=`echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
# get processors
PROCESSOR_NAME=`grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | awk {'print $0'} | head -1`
PROCESSOR_COUNT=`grep -ioP 'processor\t:' /proc/cpuinfo | wc -l`

W="\e[0;39m"
G="\e[1;32m"

temp=""
if [ -x "$(command -v landscape-sysinfo)" ]; then
  temp=$(landscape-sysinfo --sysinfo-plugins Temperature | sed 's/ *$//g' | sed 's/Temperature: //g')
fi

echo -e "
${W}system info:
$W  Distro      : $W`cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g'`
$W  Kernel      : $W`uname -sr`
$W  Uptime      : $W`uptime -p`
$W  Load        : $G$LOAD1$W (1m), $G$LOAD5$W (5m), $G$LOAD15$W (15m)
$W  Processes   :$W $G$PROCESS_ROOT$W (root), $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)
$W  CPU         : $W$PROCESSOR_NAME ($G$PROCESSOR_COUNT$W vCPU)
$W  Memory      : $G$USED$W used, $G$AVAIL$W avail, $G$TOTAL$W total$W"
temp=""
if [ -x "$(command -v landscape-sysinfo)" ]; then
  temp=$(landscape-sysinfo --sysinfo-plugins Temperature | sed 's/Temperature: //g' | sed 's/^ *//g')
fi
if [ -z "$temp" ]; then
  echo -e "$W  Temperature : $W$G$temp$W"
fi
### Disk
###########################################################

# config
max_usage=90
bar_width=50
# colors
white="\e[39m"
green="\e[1;32m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"

# disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(df -H -x zfs -x squashfs -x tmpfs -x devtmpfs -x overlay --output=target,pcent,size | tail -n+2)
printf "\ndisk usage:\n"

for line in "${dfs[@]}"; do
    # get disk usage
    usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="="
    done
    # print dimmmed bar until end
    bar+="${white}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="="
    done
    bar+="${undim}]"
    # print usage line & bar
    echo "${line}" | awk '{ printf("%-31s%+3s used out of %+4s\n", $1, $2, $3); }' | sed -e 's/^/  /'
    echo -e "${bar}" | sed -e 's/^/  /'
done

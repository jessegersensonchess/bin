#!/bin/bash
# arg 1: path to logfile

#### file descriptor 214 is the lock ####
exec 214>"/tmp/.collect-system-stats-lock-file" || exit 214
flock -n 214 || exit 214

if [[ -z "$1" ]]
then
    echo "USAGE: $0 [path_to_logfile]"
    exit 1
fi

Path="$1"
Service="SMSGate2"

Uptime=$(awk '{printf "Uptime_days=%s", $1/86400}' /proc/uptime)
Load=$(awk '{printf "Load_avg_1min=%.2f", $1}' /proc/loadavg)
Disk=$(df --block-size=1M | awk '$NF=="/"{printf "Disk_total_mb=%.2f, Disk_used_mb=%.2f, Disk_used_rel=%s", $2,$3,$5}')
Memory=$(free -m | awk 'NR==2{printf "Mem_total_mb=%s, Mem_used_mb=%s, Mem_used_rel=%.2f%%, Mem_buffcache_mb=%s, Mem_avail_mb=%s", $2,$3,$3*100/$2,$6,$7 }')
nproc=$(nproc)
vmstat=$(vmstat 1 2 | tail -1)

#### assumes primary network device is named 'eth0' ####
sar=$(sar -n DEV 1 1| grep -o eth0.* | head -1)

echo "$(date '+%Y-%m-%d %H:%M:%S') $Load, $Memory, $Disk, $Uptime, nproc=${nproc}, vmstat=${vmstat}, sar=${sar}," | sed -e "s/\s\+/ /g" -e "s/= /=/g" >> ${Path}/${Service}-$(hostname)-$(date '+%Y%m%d')-stats.log

#### release flock ####
flock -u 214



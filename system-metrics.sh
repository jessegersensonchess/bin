#!/bin/bash
# DESCRIPTION: Bash script to collect system statistics and log them to a file.
# INPUT: path (string); service_name (string)
# OUTPUT: string

# avoid concurrent runs
trap ctrl_c INT KILL TERM QUIT ABRT PWR USR2 HUP QUIT USR1

function ctrl_c() {
    echo "** Trapped signal"
    flock -u 214
    echo "** closed flock"
    exit
}

#### file descriptor 214 is the lock ####
exec 214>"/tmp/.collect-system-stats-lock-file" || exit 214
flock -n 214 || exit 214

if [[ -z "$2" ]]
then
    echo "USAGE: $0 [path_to_logfile] [service_name]"
    exit 1
fi

Path="$1" 
Service="$2" 

Uptime=$(awk '{printf "Uptime_days=%s", $1/86400}' /proc/uptime)
Load=$(awk '{printf "Load_avg_1min=%.2f", $1}' /proc/loadavg)
Disk=$(df --block-size=1M | awk '$NF=="/"{printf "Disk_total_mb=%.2f, Disk_used_mb=%.2f, Disk_used_rel=%s", $2,$3,$5}')
Memory=$(free -m | awk 'NR==2{printf "Mem_total_mb=%s, Mem_used_mb=%s, Mem_used_rel=%.2f%%, Mem_buffcache_mb=%s, Mem_avail_mb=%s", $2,$3,$3*100/$2,$6,$7 }')

# TODO: don't hardcode network device 'eth0'
if sar="$(type -p "sar")"; then
	sar=$(sar -n DEV 1 1| grep -o eth0.* | head -1)
else
	sar="sar_not_installed"
fi

if vmstat="$(type -p "vmstat")"; then
	vmstat=$(vmstat 1 2 | tail -1)
else
	vmstat="vmstat_not_installed"
fi

nproc=$(nproc)
processes=$(ps -A | wc -l)

echo "$(date '+%Y-%m-%d %H:%M:%S') ${Load}, ${Memory}, ${Disk}, ${Uptime}, nproc=${nproc}, vmstat=${vmstat}, sar=${sar}, processes=${processes}" \
     | sed -e "s/\s\+/ /g" -e "s/= /=/g" \
     >> ${Path}/${Service}-$(hostname)-$(date '+%Y%m%d')-stats.log

### release flock ####
flock -u 214

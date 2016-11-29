#!/bin/bash

xlog=/root/backup_lv.log

duration_string()
{
        # This function takes a number of seconds as an argument
        # and converts it to human friendly format like
        # 3 days 12 hours 23 minutes and 17 seconds

        xdaysd=$(($1      / 86400))     # integer divide the number by the no of secs in a day
        xdaysr=$(($1      % 86400))     # the remainder
        xhourd=$(($xdaysr /  3600))     # divide the remainder by the no of secs in an hour
        xhourr=$(($xdaysr %  3600))     # the remainder
        xminsd=$(($xhourr /    60))     # divide the number by the secs in a minute
        xminsr=$(($xhourr %    60))     # the remainder ( balance seconds )

        xoutput=""
        [ $xdaysd -eq "1" ] && xoutput="$xoutput $xdaysd day"
        [ $xdaysd -gt "1" ] && xoutput="$xoutput $xdaysd days"
        [ $xhourd -eq "1" ] && xoutput="$xoutput $xhourd hour"
        [ $xhourd -gt "1" ] && xoutput="$xoutput $xhourd hours"
        [ $xminsd -eq "1" ] && xoutput="$xoutput $xminsd minute"
        [ $xminsd -gt "1" ] && xoutput="$xoutput $xminsd minutes"
        [ $xminsr -eq "1" ] && xoutput="$xoutput $xminsr second"
        [ $xminsr -gt "1" ] && xoutput="$xoutput $xminsr seconds"

        echo "$xoutput"
}

backup_lv() {
        # This function will copy a logical volume to another computer
        # It makes a snapshot of the given logical volume, then uses dd
        # and ssh to copy to another computer with a similarly named and
        # sized logical volume, then deletes the snapshot

		# Insert Destination Address 
        xdest=172.18.0.40
        xsnap=blvs

        # Print to the log file the time we started backing up the selected logical volume
        echo "$(date +"%Y-%m-%d %H:%M:%S") Started Backup of $1" >> "$xlog"
        start="$(date +%s)"

        # the business
        /sbin/lvcreate -s  -L 10G -n ${xsnap}-${1} /dev/blk/$1
        /bin/dd bs=16M if=/dev/blk/${xsnap}-${1} | /usr/bin/ssh "$xdest" "/bin/dd bs=16M of=/dev/a4/backup-$1"
        /sbin/lvremove /dev/blk/${xsnap}-${1} -f

        # Print to the log file the time we finished backing up the selected logical volume
        end="$(date +%s)"
        diff="$(( $end - $start ))"
        echo "$(date +"%Y-%m-%d %H:%M:%S") backup of $1 completed in$(duration_string $diff)" >> "$xlog"
}


backup_lv 001
backup_lv 002

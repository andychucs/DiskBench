#!/bin/bash
# Parameter1:filename Parameter2:RAID/JBOD Parameter3:name
# Run 'smartctl --scan' to define disk number in smart() function.

smart() {
  time=$(date "+%Y-%m-%d %H:%M:%S")
  smartctl -a /dev/bus/4 -d megaraid,3 >> $time-disk6-smart.log
  smartctl -a /dev/bus/4 -d megaraid,4 >> $time-disk7-smart.log
  smartctl -a /dev/bus/4 -d megaraid,5 >> $time-disk8-smart.log
  smartctl -a /dev/bus/4 -d megaraid,6 >> $time-disk9-smart.log

}

jbod_stress() {
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=write -bs=1M -numjobs=10 -allow_mounted_write=1 -size=10% -loops=2 -name=$2
  smart
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=randwrite -bs=4K -numjobs=1 -runtime=10h --write_bw_log=jbod_randwrite --write_lat_log=jbod_randwrite --write_iops_log=jbod_randwrite --log_avg_msec=1000 -allow_mounted_write=1 -name=$2
  smart
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=randread -bs=4K -numjobs=1 -runtime=2h --write_bw_log=jbod_randread --write_lat_log=jbod_randread --write_iops_log=jbod_randread --log_avg_msec=1000 -allow_mounted_write=1 -name=$2
  smart
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=randrw rwmixread=70 -bs=4K -numjobs=1 -runtime=2h --write_bw_log=jbod_randrw --write_lat_log=jbod_randrw --write_iops_log=jbod_randrw --log_avg_msec=1000 -allow_mounted_write=1 -name=$2
  smart
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=write -bs=1024K -numjobs=1 -runtime=2h --write_bw_log=jbod_write --write_lat_log=jbod_write --write_iops_log=jbod_write --log_avg_msec=1000 -allow_mounted_write=1 -name=$2
  smart
  fio -ioengine=libaio -filename=$1 -direct=1 -iodepth=32 -thread -rw=read -bs=1024K -numjobs=1 -runtime=10h --write_bw_log=jbod_read --write_lat_log=jbod_read --write_iops_log=jbod_read --log_avg_msec=1000 -allow_mounted_write=1 -name=$2
  smart
}

raid_stress() {
  full_size=$(df -Bm | grep $1 | awk '{print $2}')

  if [ "$2"x = "1m_read"x ]; then
    fio --name=raid_stress_$2 --ioengine=libaio --size=$full_size --direct=1 --rw=read --bs=1024k --loop=1000 --runtime=14400 --write_bw_log=raid_read --write_lat_log=raid_read --write_iops_log=raid_read --log_avg_msec=1000 --directory=$1
    echo "$2 RAID Stress was finished. Run './stress.sh $1 RAID 4k_randread' to continue."
  elif [ "$2"x = "4k_randread"x ]; then
    fio --name=raid_stree_$2 --ioengine=libaio --size=$full_size --direct=1 --rw=randread --bs=4k --loop=1000 --runtime=14400 --write_bw_log=raid_randread --write_lat_log=raid_randread --write_iops_log=raid_randread --log_avg_msec=1000 --directory=$1
    echo "$2 RAID Stress was finished. Run './stress.sh $1 RAID 4k_randwrite' to continue."
  elif [ "$2"x = "4k_randwrite"x ]; then
    fio --name=raid_stree_$2 --ioengine=libaio --size=$full_size --direct=1 --rw=randwrite --bs=4k --loop=1000 --runtime=14400 --write_bw_log=raid_randwrite --write_lat_log=raid_randwrite --write_iops_log=raid_randwrite --log_avg_msec=1000 --directory=$1
    echo "$2 RAID Stress was finished. Run './stress.sh $1 RAID 4k_randrw' to continue."
  elif [ "$2"x = "4k_randrw"x ]; then
    fio --name=raid_stree_$2 --ioengine=libaio --size=$full_size --direct=1 -rw=randrw rwmixread=70 --bs=4k --loop=1000 --runtime=14400 --write_bw_log=raid_randrw --write_lat_log=raid_randrw --write_iops_log=raid_randrw--log_avg_msec=1000 --directory=$1
    echo "$2 RAID Stress was finished. Run './stress.sh $1 RAID 1m_read' to restart."
  fi
  smart
}

if [ "$2"x = "JBOD"x ]; then
  jbod_stress $1 $3
elif [ "$2"x = "RAID"x ]; then
  raid_stress $1 $3
fi

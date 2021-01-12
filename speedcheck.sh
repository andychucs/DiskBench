#!/bin/bash

#for i in `grep -l Gbps /sys/class/ata_link/*/sata_spd`; do
# echo Link "${i%/*}" Speed `cat $i`
# cat "${i%/*}"/device/dev*/ata_device/dev*/id | perl -nE 's/([0-9a-f]{2})/print chr hex $1/gie' | echo "    " Device `strings` | cut -f 1-3
#done

IFS=$'\n'
time=$(date "+%Y-%m-%d %H:%M:%S")
echo $time >> speedcheck.log
devs=$(smartctl --scan | grep raid | awk -F'#' '{print $1}')
for i in $devs; do
  IFS=' '
  smart=$(smartctl -a ${i})
  sn=$(echo $smart | grep 'Serial Number')
  sata_spd=$(echo $smart | grep 'SATA')
  echo $sn,$sata_spd >> speedcheck.log
done
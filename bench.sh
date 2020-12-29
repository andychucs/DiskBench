#!/bin/bash
# Parameter1:filename Parameter2:size Parameter3:name

v=$(fio -v)
echo 'bs,rw,IPOS,BW(MB/s),lat(min),lat(max),lat(avg),cpu(usr)' >> $3-${v}-bench.csv
fio -filename=$1  -direct=1 -iodepth=1 -thread -rw=write -bs=1M  -numjobs=10 -allow_mounted_write=1 -size=10% -loops=1 -name=$3
fio -filename=$1  -direct=1 -iodepth=1 -thread -rw=randwrite -bs=4K -numjobs=10 -runtime=7200 -allow_mounted_write=1 -name=$3


bench(){
    for i in 1 4 8 16 32 64 128 1024
    do
        fio -ioengine=libaio -filename=$1  -direct=1 -iodepth=32 -thread -rw=$4 -bs=${i}K -numjobs=1 -group_reporting -size=$2  -allow_mounted_write=1 -name=$3-$4-bench | tee $3-$4-bench-${i}K.log
        # str1=$(cat $3-$4-bench-${i}K.log | grep IOPS | python -c "import re;print(','.join(re.findall(r'\d+\.?\d*[\d|k]',raw_input())[0:3:2]))")

        iops=$(cat $3-$4-bench-${i}K.log | grep IOPS | awk -F, '{print $1}' | awk -F= '{print $2}')
        bwm=$(cat $3-$4-bench-${i}K.log | grep IOPS | awk -F'(' '{print $2}' | awk -F'M' '{print $1}')
        str1=$iops','$bwm

        sec=$(cat $3-$4-bench-${i}K.log | grep ' lat (' | awk 'NR==1' | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
        ratio=1
        if [ "$sec"x = "msec"x ]
        then
            ratio=1000
        elif [ "$sec"x = "usec"x ]
        then
            ratio=1000000
        elif [ "$sec"x = "nsec"x ]
        then
            ratio=1000000000
        fi
        str2=$(cat $3-$4-bench-${i}K.log | grep ' lat (' | awk 'NR==1' | python -c "import re;print(','.join([ str(float(x)/$ratio) for x in re.findall(r'\d+\.?\d*',raw_input())][0:-1]));")

        str3=$(cat $3-$4-bench-${i}K.log | grep cpu | python -c "import re;print(re.findall(r'\d+\.?\d*[%]',raw_input())[0])")
        str=${i}'K,'$4','$str1','$str2','$str3
        echo $str >> $3-${v}-bench.csv
    done
}

bench $1 $2 $3 'randwrite'
fio -filename=$1  -direct=1 -iodepth=1 -thread -rw=randwrite -bs=4K -numjobs=10 -size=10% -loops=2 -allow_mounted_write=1 -name=$3
bench $1 $2 $3 'randread'
fio -filename=$1  -direct=1 -iodepth=1 -thread -rw=write -bs=1M  -numjobs=10 -allow_mounted_write=1 -size=10% -loops=2 -name=$3
bench $1 $2 $3 'write'
bench $1 $2 $3 'read'

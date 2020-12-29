# 磁盘性能测试脚本

author: Andy
version: 0.0.1

## 使用方法

1. 解压fio.tar。

2. 在fio路径下执行：

   ```shell
   ./configure 
   make -j64
   make install
   ```
   
3. 在当前路径执行`bench.sh {磁盘路径} {测试使用空间} {被测硬盘型号-物理盘数量和RAID/JBOD类型}`。


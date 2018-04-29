#/bin/sh
#
# NAND DUMPER FOR NINTENDO SWITCH
# ARCH LINUX ENV REQUIRED
###############################################################################
echo ''
echo ' _  _  _  _  _ __    __  _ _ _   _ ___    '
echo '| \| |/ \| \| |  \  |  \| | | \_/ | o \  '
echo '| \\ | o | \\ | o ) | o | U | \_/ |  _/  '
echo '|_|\_|_n_|_|\_|__/  |__/|___|_| |_|_|    '
echo ''
DCFLDINST=`pacman -Ss dcfldd | grep 'installed'`
if [ -z "$DCFLDINST" ];
then
  echo 'dcfldd installation'
  pacman -S dcfldd
fi
echo ''
echo '=> BOOT 0 PARTITION DUMP'
dcfldd if=/dev/mmcblk1boot0 of=nand_boot0_dump.bin
echo
echo 'dumped in nand_boot0_dump.bin'
echo ''
echo '=> BOOT 1 PARTITION DUMP'
dcfldd if=/dev/mmcblk1boot1 of=nand_boot1_dump.bin
echo 'dumped in nand_boot1_dump.bin'
echo ''
echo '=> TSEC FW EXTRACTION (FOR BIS KEY DUMPER)'
OFFSETS=`cat nand_boot0_dump.bin | hexdump -C | grep '4d 00 42 cf'`
OFFSET1=`echo $OFFSETS | cut -c1-8`
OFFSET1=`echo '0x'$OFFSET1`
echo 'Extracting from offset : ' $OFFSET1
dcfldd skip=$(($OFFSET1)) count=3840 if=/dev/mmcblk1boot0 of=tsecfw.bin bs=1
cat tsecfw.bin | hexdump -v -e '16/1 "0x%x," "\n"' > tsecfw.inl
rm tsecfw.bin
echo ''
echo '=> USER PARTITIONS DUMP'
echo 'This may take a while...'
dcfldd if=/dev/mmcblk1 | gzip -c --fast | dcfldd of=nand.bin.gz
echo 'dumped in nand.bin.gz'
echo ''
echo 'YOUR NAND IS FULLY DUMPED !'

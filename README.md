# homeTask2
1. Создали простой вангрант файл, без авторейда.Стартуем виртуалку с 5 дисками.
[vagrant@otuslinux ~]$ lsscsi             
[0:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sda 
[3:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdb 
[4:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdc 
[5:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdd 
[6:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sde 
[7:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdf 

Соберем RAID5.
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}

Убедимся, что все собралось

[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]


2. Попробуем сломать и починить.
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --fail /dev/sde

mdadm: set /dev/sde faulty in /dev/md0

Видно что помечен теперь как поломанный:

[vagrant@otuslinux ~]$ watch cat /proc/mdstat

Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sdf[5] sde6 sdd[2] sdc[1] sdb[0]

  1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]

Уберем его, чтобы заменить на новый:

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sde

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sde

mdadm: added /dev/sde

[vagrant@otuslinux ~]$ cat /proc/mdstat

Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sde[6] sdf[5] sdd[2] sdc[1] sdb[0]

  1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]

  [=================>...]  recovery = 87.7% (223488/253952) finish=0.0min speed=18624K/sec

unused devices:

Восстановление прошло успешно:

[vagrant@otuslinux ~]$ cat /proc/mdstat

Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sde[6] sdf[5] sdd[2] sdc[1] sdb[0]

  1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: 

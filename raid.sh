#!/bin/bash           

            mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
            mdadm --create --verbose --force /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
            cat /proc/mdstat
            mkdir /etc/mdadm/
            echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
            mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
            parted -s /dev/md0 mklabel gpt
            parted /dev/md0 mkpart primary ext4 0% 20%
            parted /dev/md0 mkpart primary ext4 20% 40%
            parted /dev/md0 mkpart primary ext4 40% 60%
            parted /dev/md0 mkpart primary ext4 60% 80%
            parted /dev/md0 mkpart primary ext4 80% 100%
            for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
            mkdir -p /raid/part{1,2,3,4,5}
            for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
            echo "#NEW DEVICE" >> /etc/fstab
            for i in $(seq 1 5); do echo `sudo blkid /dev/md0p$i | awk '{print $2}'` /u0$i ext4 defaults 0 0 >> /etc/fstab; done
            sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd

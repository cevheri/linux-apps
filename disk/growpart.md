# Growpart and resize disk



➜  ~ lsblk
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0  100G  0 disk 
|-sda1   8:1    0    1G  0 part /boot/efi
|-sda2   8:2    0    1G  0 part /boot
|-sda3   8:3    0    2G  0 part [SWAP]
`-sda4   8:4    0   45G  0 part /
```

---

➜  ~ lsblk -f
```
NAME   FSTYPE   FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                             
|-sda1 vfat     FAT32       FFE4-C080                                 1G     1% /boot/efi
|-sda2 ext4     1.0         22a8fd3e-6770-4156-9449-6b13cb8ce152  653.6M    26% /boot
|-sda3 swap     1           e8f88dba-0955-47e4-aada-42e8a42a45ec                [SWAP]
`-sda4 ext4     1.0         a5a6a021-3bcc-4b83-bddb-4c7d6a4d80a2   22.5G    44% /
```

---
```shell
sudo apt install cloud-guest-utils
```

---

sudo growpart /dev/sda 4
```
CHANGED: partition=4 start=8495104 old: size=94371840 end=102866944 new: size=201220063 end=209715167
```

---

sudo resize2fs /dev/sda4
```
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/sda4 is mounted on /; on-line resizing required
old_desc_blocks = 6, new_desc_blocks = 12
The filesystem on /dev/sda4 is now 25152507 (4k) blocks long.
```

---

df -h
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           392M  1.2M  390M   1% /run
/dev/sda4        95G   20G   71G  22% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda2       974M  253M  654M  28% /boot
/dev/sda1       1.1G  6.1M  1.1G   1% /boot/efi
tmpfs           392M  4.0K  392M   1% /run/user/1000
```

---

➜  ~ lsblk
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sda      8:0    0  100G  0 disk 
|-sda1   8:1    0    1G  0 part /boot/efi
|-sda2   8:2    0    1G  0 part /boot
|-sda3   8:3    0    2G  0 part [SWAP]
`-sda4   8:4    0 95.9G  0 part /
```

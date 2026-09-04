#!/bin/sh
. /etc/init.d/tc-functions
useBusybox

use32(){
  VMLINUZ="vmlinuz"
  ROOTFS="core"
  BUILD="x86"
}

use64(){
  VMLINUZ="vmlinuz64"
  ROOTFS="corepure64"
  BUILD="x86_64"
}

abort(){
  echo -n "Press Enter to exit."
  read gagme
  exit 1
}

find_source_media(){
  MY_SOURCE_DIR=""
  
  for mnt_point in /mnt/*; do
    if [ -d "$mnt_point/boot" ] && [ -d "$mnt_point/EFI" ] && [ -d "$mnt_point/cde" ]; then
      if [ -f "$mnt_point/boot/$VMLINUZ" ] && [ -f "$mnt_point/boot/$ROOTFS.gz" ]; then
        MY_SOURCE_DIR="$mnt_point"
        break
      fi
    fi
  done

  if [ -z "$MY_SOURCE_DIR" ]; then
    for mnt_point in /mnt/*; do
      if [ -d "$mnt_point/boot" ] || [ -d "$mnt_point/cde" ] || [ -d "$mnt_point/EFI" ]; then
        MY_SOURCE_DIR="$mnt_point"
        break
      fi
    done
  fi

  if [ -z "$MY_SOURCE_DIR" ] || [ ! -d "$MY_SOURCE_DIR" ]; then
    MY_SOURCE_DIR=$(dirname $(realpath $0))
    echo "Fallback to script directory: $MY_SOURCE_DIR"
  fi
}

partition_setup_hybrid(){
  echo "Creating partition in device '$DEVICE'"
  dd if=/dev/zero of=/dev/$DEVICE bs=1k count=1 > /dev/null 2>&1
  sync; sleep 1
  
  echo -e "g\nn\n1\n\n\nt\n1\nw" | fdisk /dev/$DEVICE > /dev/null 2>&1
  sync; sleep 1
}

copy_my_distro(){
  echo "Copying system files..."
  [ -d /mnt/drive/tce ] || mkdir -p /mnt/drive/tce/optional
  
  cp $MY_SOURCE_DIR/boot/$VMLINUZ $BOOTDIR/
  cp $MY_SOURCE_DIR/boot/$ROOTFS.gz $BOOTDIR/

  if [ -d $MY_SOURCE_DIR/cde ]; then
    if [ -d $MY_SOURCE_DIR/cde/optional ]; then
      cp -r $MY_SOURCE_DIR/cde/optional/* /mnt/drive/tce/optional/
    fi
    cp $MY_SOURCE_DIR/cde/*.lst /mnt/drive/tce/ 2>/dev/null
    cp $MY_SOURCE_DIR/cde/*.instlist /mnt/drive/tce/ 2>/dev/null
    
    if [ -f /mnt/drive/tce/onboot.lst ]; then
      :
    elif [ -f /mnt/drive/tce/copy2fs.lst ]; then
      cp /mnt/drive/tce/copy2fs.lst /mnt/drive/tce/onboot.lst
    elif [ -f /mnt/drive/tce/xbase.lst ]; then
      cp /mnt/drive/tce/xbase.lst /mnt/drive/tce/onboot.lst
    fi
  fi
  
  chown -R tc.staff /mnt/drive/tce 2>/dev/null
  chmod -R u+w /mnt/drive/tce 2>/dev/null
}

dual_boot_setup(){
  mount -t vfat /dev/$TARGET /mnt/drive
  if [ $? != 0 ]; then
    echo "Error mounting target device"
    abort
  fi
  
  mkdir -p $BOOTDIR
  copy_my_distro

  
   /mnt/drive/syslinux.cfg
  
  sync
  dd if=/usr/local/share/syslinux/mbr.bin of=/dev/$DEVICE bs=440 count=1 > /dev/null 2>&1
  syslinux --install /dev/$TARGET > /dev/null 2>&1

  mkdir -p /mnt/drive/boot/grub
  if [ -d $MY_SOURCE_DIR/boot/grub ]; then
    cp -r $MY_SOURCE_DIR/boot/grub/* /mnt/drive/boot/grub/
  fi

  if [ -d $MY_SOURCE_DIR/EFI ]; then
    mkdir -p /mnt/drive/EFI
    cp -r $MY_SOURCE_DIR/EFI/* /mnt/drive/EFI/
  fi
  sync
  umount /mnt/drive
}

ui_select_target(){
  clear
  echo "=== Control OC Installer ==="
  echo "Available disks and partitions:"
  fdisk -l 2>/dev/null | grep -E "^Disk /dev/|^/dev/"
  echo "----------------------------------------"
  echo -n "Enter target disk (e.g., sda): "
  read TARGET_INPUT
  
  if [ -z "$TARGET_INPUT" ]; then
    echo "No target device selected."
    abort
  fi
  
  DEVICE="$TARGET_INPUT"
  TARGET="${DEVICE}1"
  [ "$(echo $DEVICE | grep -o '[[:alpha:]]*')" = "mmcblk" ] && TARGET="${DEVICE}p1"
  [ "$(echo $DEVICE | grep -o '^[[:alpha:]]*')" = "nvme" ] && TARGET="${DEVICE}p1"
}

checkroot

[ "$(uname -m)" = "i686" ] && use32 || use64

find_source_media

ui_select_target

clear
echo "WARNING! ALL DATA ON DEVICE '$DEVICE' WILL BE COMPLETELY DESTROYED!"
echo -n "Continue installation? (y/n): "
read answer
if [ "$answer" != "y" ]; then
  if [ "$answer" = "n" ]; then
    echo "User is aborted the installation."
    exit 0
  else
    echo "The answer is wrong. Please response (y/n) in a question. Run this utility again."
    exit 0
fi

grep -q ^/dev/"$DEVICE" /etc/mtab && {
  echo "$DEVICE is already mounted! Please unmount it before proceeding."
  abort
}

BOOTDIR="/mnt/drive/tce/boot"
BOOTPATH="/tce/boot"
OPTIONS="syslog showapps"
FORMAT="vfat"

partition_setup_hybrid
rebuildfstab

echo "Preparing disk for installation..."
mkfs.vfat -F 32 /dev/$TARGET > /dev/null || abort
sync; sleep 1

[ -d /mnt/drive ] || mkdir /mnt/drive
TARGETUUID="$(blkid -s UUID /dev/${TARGET} | awk '{print $2}' | tr -d '"')"

dual_boot_setup

echo -e "a\n1\nw" | fdisk /dev/$DEVICE > /dev/null 2>&1
hdparm -z /dev/$DEVICE > /dev/null 2>&1
sync; sleep 1

clear
echo "=== Installation Completed Successfully ==="
exit 0

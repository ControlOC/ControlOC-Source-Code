#!/usr/bin/bash

ISO="$(cat /tmp/data_folder.dat)"
ISO_PATH="${ISO}/controloc_hdd.iso"

while true; do
    echo "List of disks:"
    lsblk -d -o NAME,SIZE,TYPE
    echo ""
    read -p "Write name of the disk to install (for example, sda): " DISK_NAME
    DISK_PATH="/dev/$DISK_NAME"

    if [ -b "$DISK_PATH" ]; then
        echo "You selected disk '$DISK_PATH'."
        read -p "WARNING! ALL DATAS ON THIS DISK WILL BE DELETED! You agree? (yes/no): " CONFIRM
        if [ "$CONFIRM" = "yes" ]; then
            break
        else
            echo "Installer stoped."
            exit 1
        fi
    else
        echo "Wrong name of disk '$DISK_PATH'. Please, select disk from list."
    fi
done

echo "Checking free space... Please, wait"
REQUIRED_SPACE_MB=1024 # 1 GB
AVAILABLE_SPACE_MB=$(df -m --output=avail "$DISK_PATH" | tail -n 1)

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "Error: No enough free space on a disk '$DISK_PATH'."
    echo "Needed: 1 GB, free: $AVAILABLE_SPACE_MB MB"
    exit 1
fi

echo "Creating partitions on $DISK_PATH..."
sudo parted -s "$DISK_PATH" mklabel gpt
sudo parted -s "$DISK_PATH" mkpart primary fat32 1MiB 501MiB
sudo parted -s "$DISK_PATH" set 1 esp on
sudo parted -s "$DISK_PATH" mkpart primary ext4 502MiB 100%

echo "Cleaning up partitions..."
sudo mkfs.fat -F32 "${DISK_PATH}1"
sudo mkfs.ext4 "${DISK_PATH}2"

echo "Mounting partitions and getting ready the ISO..."
sudo mkdir -p /mnt/iso /mnt/esp /mnt/root
sudo mount -o loop "$ISO_PATH" /mnt/iso
sudo mount "${DISK_PATH}1" /mnt/esp
sudo mount "${DISK_PATH}2" /mnt/root

echo "Copying files... This will take from 10 seconds to 2 minutes"
sudo cp -r /mnt/iso/EFI /mnt/esp/
sudo cp /mnt/iso/boot/vmlinuz64 /mnt/esp/EFI/BOOT/
sudo cp /mnt/iso/boot/corepure64.gz /mnt/esp/EFI/BOOT/

echo "Setting up system files... Please, wait!"
ROOT_PARTITION_UUID=$(sudo blkid -s UUID -o value "${DISK_PATH}2")
GRUB_CONFIG_FILE="/mnt/esp/EFI/BOOT/grub.cfg"

cat << EOF | sudo tee "$GRUB_CONFIG_FILE" > /dev/null
menuentry "ControlOC" {
    linux vmlinuz64 changes=UUID=$ROOT_PARTITION_UUID quiet
    initrd corepure64.gz
}
EOF

sudo umount /mnt/iso
sudo umount /mnt/esp
sudo umount /mnt/root

echo "Control OC is ready to start."
read -p "Reboot computer to system? (yes/no) " REBOOT_CONFIRM
if [ "$REBOOT_CONFIRM" = "yes" ]; then
    sudo reboot
else
    echo "Restart the computer when you was ready."
fi

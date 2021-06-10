#!/bin/bash

# Run this script in the live system after installation to migrate

user_name="nulysses"
user_id="12345"
group_id="12346"
source_uuid="82c8edcd-3aa5-4937-ba1f-34ac1887c771"
target_uuid="43751c3c-019c-4d6f-a92c-2b654fa7b824"

read -p "secret? " secret

# Close luks used by installer
cryptsetup close "luks-${target_uuid}"

echo "${secret}" | cryptsetup open "/dev/disk/by-uuid/${target_uuid}" new_system
mkdir -p /mnt/new_system
mount "/dev/mapper/new_system" "/mnt/new_system"


echo "${secret}" | cryptsetup open "/dev/disk/by-uuid/${source_uuid}" old_system
mkdir -p /mnt/old_system
mount "/dev/mapper/old_system" "/mnt/old_system"

chroot "/mnt/new_system" usermod -u "${user_id}" "${user_name}"
chroot "/mnt/new_system" groupmod -g "${group_id}" "${user_name}"

rsync -aAXv --delete "/mnt/old_system/home/${user_name}/" "/mnt/new_system/home/${user_name}"
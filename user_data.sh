#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install docker.io docker-compose git -y
sudo usermod -aG docker ubuntu
sudo mount -a

# Replace these values with your own
EFS_FILE_SYSTEM_ID="fs-08e00c647710edcc5"
EFS_REGION="us-east-1"
EFS_MOUNT_POINT="/home/ubuntu/efs-jellyfin/"

# Install NFS client if not already installed
sudo apt-get install -y nfs-common

# Create the mount point directory if it doesn't exist
sudo mkdir -p $EFS_MOUNT_POINT

# Mount the EFS file system
sudo mount -t nfs4 $EFS_FILE_SYSTEM_ID.efs.$EFS_REGION.amazonaws.com:/ $EFS_MOUNT_POINT

# Add the mount command to /etc/fstab to mount the EFS automatically on boot
echo "$EFS_FILE_SYSTEM_ID.efs.$EFS_REGION.amazonaws.com:/ $EFS_MOUNT_POINT nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Set appropriate permissions on the mount point
sudo chown ec2-user:ec2-user $EFS_MOUNT_POINT

# Check if the mount was successful
if mountpoint -q $EFS_MOUNT_POINT; then
    echo "EFS mounted successfully at $EFS_MOUNT_POINT"
else
    echo "Failed to mount EFS"
fi

git clone https://github.com/heitorlourencosilva/Oficina12Grupo1.git
cd Oficina12Grupo1/
docker-compose up -d

sudo reboot

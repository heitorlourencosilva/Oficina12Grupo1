#!/bin/bash
sudo apt update
sudo apt install -y s3fs
sudo echo "s3fs#g1-jellyfin /home/ubuntu/s3-jellyfin fuse _netdev,allow_other,iam_role,url=http://s3.amazonaws.com 0 0" | sudo tee -a /etc/fstab
sudo mkdir /home/ubuntu/s3-jellyfin
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

#!/bin/bash
# Remove old local manifests
rm -rf .repo/local_manifests

# Initialize repo with Lineage manifest
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs

# Clone local manifests
git clone https://github.com/adarsh0s/local_manifest .repo/local_manifests

# Sync Repo 
repo sync

# Run resync script
/opt/crave/resync.sh

# Source environment and lunch target
source build/envsetup.sh
export RELAX_USES_LIBRARY_CHECK=true
lunch lineage_devonf-bp1a-userdebug

rm -rf device/google/cuttlefish_vmm

# Start the build
mka target-files-package otatools
wget https://raw.githubusercontent.com/adarsh0s/scripts/refs/heads/main/create_keys.sh
chmod +x create_keys.sh
bash create_keys.sh
wget https://raw.githubusercontent.com/adarsh0s/scripts/refs/heads/main/sign.sh
chmod +x sign.sh
bash sign.sh
ota_from_target_files -k ~/.android-certs/releasekey \
    --block --backup=true \
    signed-target_files.zip \
    signed-ota_update.zip

# Upload the build on completion
wget https://raw.githubusercontent.com/Sushrut1101/GoFile-Upload/refs/heads/master/upload.sh 
chmod +x upload.sh 
./upload.sh signed-ota_update.zip

# Delete Keys on Completion
rm -rf ~/.android-certs

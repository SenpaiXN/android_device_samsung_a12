# Clone Depedencie 
git clone https://github.com/SenpaiXN-Development/android_vendor_samsung_a12 vendor/samsung/a12
git clone https://github.com/SenpaiXN-Development/android_kernel_samsung_a12 kernel/samsung/a12
git clone https://github.com/lineageos/android_hardware_samsung -b lineage-21 hardware/samsung_ext

# Selinux patch
echo "------------------------------------------------"
echo " We dont need selinux from Ram boost,iso,udf,aux "
echo "------------------------------------------------"

# Define search paths
SYSTEM_PRIVATE_DIR="system/sepolicy/private/"
DEVICE_DIR="device/"

# Define the patterns to search and comment out
SYSTEM_PATTERNS=(
  "genfscon proc /sys/kernel/sched_nr_migrate u:object_r:proc_sched:s0"
  "genfscon proc /sys/vm/compaction_proactiveness u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/extfrag_threshold u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/swap_ratio u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/swap_ratio_enable u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/page_lock_unfairness u:object_r:proc_drop_caches:s0"
)

DEVICE_PATTERNS=(
  "vendor.camera.aux.packageexcludelist   u:object_r:vendor_persist_camera_prop:s0"
  "vendor.camera.aux.packagelist          u:object_r:vendor_persist_camera_prop:s0"
)

ISO_UDF_PATTERNS=(
  "type iso9660, sdcard_type, fs_type, mlstrustedobject;"
  "type udf, sdcard_type, fs_type, mlstrustedobject;"
  "genfscon iso9660 / u:object_r:iso9660:s0"
  "genfscon udf / u:object_r:udf:s0"
)

# Function to search and comment lines in files
comment_lines() {
  local dir=$1
  local patterns=("${!2}")
  local msg=$3
  local found=0
  
  for pattern in "${patterns[@]}"; do
    # Find files containing the pattern
    files=$(grep -rl "$pattern" "$dir")
    
    for file in $files; do
      # Comment the line if found
      sed -i "s|$pattern|# $pattern|" "$file"
      found=1
    done
  done
  
  if [ $found -eq 1 ]; then
    echo "$msg found"
  fi
}

# Search in system/private/ and comment if found
comment_lines "$SYSTEM_PRIVATE_DIR" SYSTEM_PATTERNS[@] "ram boost"

# Search in device/ and comment if found
comment_lines "$DEVICE_DIR" DEVICE_PATTERNS[@] "aux cam"

# Search for ISO and UDF patterns
comment_lines "$DEVICE_DIR" ISO_UDF_PATTERNS[@] "iso and udf"

echo "------------------------------------------------"
echo "Selinux Patching Done"
echo "------------------------------------------------"

#sysbta patch
wget https://raw.githubusercontent.com/SenpaiXN-Development/android_device_samsung_a04e/refs/heads/lineage-22.1/patches/bt-audio.patch
wget https://raw.githubusercontent.com/SenpaiXN-Development/android_device_samsung_a04e/refs/heads/lineage-22.1/patches/frame-1-15.patch
wget https://raw.githubusercontent.com/SenpaiXN-Development/android_device_samsung_a04e/refs/heads/lineage-22.1/patches/frame-2-15.patch
wget https://raw.githubusercontent.com/SenpaiXN-Development/android_device_samsung_a04e/refs/heads/lineage-22.1/patches/proc.patch
wget https://raw.githubusercontent.com/SenpaiXN-Development/android_device_samsung_a04e/refs/heads/lineage-22.1/patches/sms-15.patch

# Applying Patches
echo "applying patches"
git apply bt-audio.patch
git apply frame-1-15.patch
git apply frame-2-15.patch
git apply sms-15.patch 
git apply proc.patch

## DONE ##
echo "applying patches done"

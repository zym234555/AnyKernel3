### AnyKernel3 Ramdisk Mod Script
## KernelSU with SUSFS By Numbersf
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    4.1*) ksu_supported=true ;;
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> 非 GKI 设备，安装中止。"

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # 针对含有 init_boot 的设备
    flash_boot # 针对含有 init_boot 的设备
else
    dump_boot # 跳过 ramdisk 解包，例如针对含有 init_boot 的设备
    write_boot # 跳过 ramdisk 重新打包，例如针对含有 init_boot 的设备
fi
## end boot install

ui_print "Power by GitHub@Numbersf(Aq1298&咿云冷雨)"

# 设置路径和文件名
KSUD_PATH="/data/adb/ksud"
MAGISK_DB_PATH="/data/adb/magisk.db"
MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+.zip"

# 根据条件下载 SUSFS 模块（来自 CI 或 Release）
if [ "${SUSFS_CI}" == "true" ]; then
    # 从 CI 下载最新的模块
    LATEST_RUN_ID=$(curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
      "https://api.github.com/repos/sidex15/susfs4ksu-module/actions/runs" | jq -r '.workflow_runs[0].id')  
    ARTIFACT_URL=$(curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
      "https://api.github.com/repos/sidex15/susfs4ksu-module/actions/runs/$LATEST_RUN_ID/artifacts" | jq -r '.artifacts[0].archive_download_url')  
    curl -L -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" -o $AKHOME/ksu_module_susfs.zip "$ARTIFACT_URL"
else
    # 从 Release 下载最新的模块
    wget https://github.com/sidex15/ksu_module_susfs/releases/latest/download/ksu_module_susfs_1.5.2+.zip -O $AKHOME/ksu_module_susfs.zip
fi

# 如果模块存在，安装 SUSFS 模块
if [ -f "$KSUD_PATH" ]; then
    /data/adb/ksud module install "$MODULE_PATH"
fi

# 安装 Magisk 模块
if [ -f "$MAGISK_DB_PATH" ]; then
    magisk --install-module "$MODULE_PATH"
    find /data/adb -name "*magisk*" -exec rm -rf {} +
fi

# 如果 APK 存在，安装 APK
if [ -f "$AKHOME/ksun.apk" ]; then
    pm install "$AKHOME/ksun.apk"
    pm uninstall me.weishu.kernelsu
fi
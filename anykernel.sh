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
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" ] || [ -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
else
    dump_boot
    write_boot
fi

ui_print "Power by GitHub@Numbersf(Aq1298&咿云冷雨)"

# 设置路径和文件名
KSUD_PATH="/data/adb/ksud"
MAGISK_DB_PATH="/data/adb/magisk.db"

# 优先选择模块路径
if [ -f "$AKHOME/ksu_module_susfs_1.5.2+.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+.zip"
    ui_print "  -> Installing SUSFS module from Release (1.5.2+)"
elif [ -f "$AKHOME/ksu_module_susfs.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs.zip"
    ui_print "  -> Installing SUSFS module from CI"
else
    ui_print "  -> No SUSFS module found!"
    exit 1
fi

# 确认 KSUD 是否存在并安装模块
if [ -f "$KSUD_PATH" ]; then
    ui_print "  -> Found KSUD at $KSUD_PATH"
    if "$KSUD_PATH" module install "$MODULE_PATH"; then
        ui_print "  -> SUSFS module installed successfully via KSUD"
    else
        ui_print "  -> Failed to install SUSFS module via KSUD"
    fi
else
    ui_print "  -> KSUD not found, skipping KSUD installation"
fi

# 通过 Magisk 安装模块（如果存在）
if [ -f "$MAGISK_DB_PATH" ]; then
    if magisk --install-module "$MODULE_PATH"; then
        ui_print "  -> SUSFS module installed successfully via Magisk"
        find /data/adb -name "*magisk*" -exec rm -rf {} +
    else
        ui_print "  -> Failed to install SUSFS module via Magisk"
    fi
else
    ui_print "  -> Magisk not found, skipping Magisk installation"
fi

# 如果 APK 存在，安装 APK
if [ -f "$AKHOME/ksun.apk" ]; then
    if pm install "$AKHOME/ksun.apk"; then
        ui_print "  -> KSU app installed successfully"
        pm uninstall me.weishu.kernelsu
    else
        ui_print "  -> Failed to install KSU app"
    fi
fi
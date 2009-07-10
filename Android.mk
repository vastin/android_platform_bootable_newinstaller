ifeq ($(TARGET_ARCH),x86)
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

#LIVECD_PATH := $(LOCAL_PATH)

LOCAL_MODULE := newinstaller
LOCAL_MODULE_TAGS := system_builder

initrd_dir := $(LOCAL_PATH)/initrd
initrd_bin := \
	$(initrd_dir)/init \
	$(wildcard $(initrd_dir)/*/*)

installer_ramdisk := $(PRODUCT_OUT)/initrd.img
$(installer_ramdisk): $(initrd_bin) | $(ACP)
	rm -rf $(TARGET_INSTALLER_OUT)
	$(ACP) -pr $(initrd_dir) $(TARGET_INSTALLER_OUT)
	ln -s /bin/ld-linux.so.2 $(TARGET_INSTALLER_OUT)/lib
	mkdir -p $(addprefix $(TARGET_INSTALLER_OUT)/,android mnt proc sys sbin tmp)
	$(MKBOOTFS) $(TARGET_INSTALLER_OUT) | gzip -9 > $@

boot_dir := $(LOCAL_PATH)/boot
boot_bin := $(wildcard $(boot_dir)/isolinux/*)

BUILT_IMG := $(addprefix $(PRODUCT_OUT)/,ramdisk.img system.img initrd.img)
BUILT_IMG += $(if $(TARGET_PREBUILT_KERNEL),$(TARGET_PREBUILT_KERNEL),$(PRODUCT_OUT)/kernel)

ISO_IMAGE := $(PRODUCT_OUT)/$(TARGET_PRODUCT).iso
$(ISO_IMAGE): $(BUILT_IMG) $(boot_bin)
	@echo ----- Making iso image ------
	genisoimage -vJURT -b isolinux/isolinux.bin -c isolinux/boot.cat \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		-input-charset utf-8 -V "Android LiveCD" -o $@ \
		$(boot_dir) $(BUILT_IMG)

.PHONY: iso_img
iso_img: $(ISO_IMAGE)

endif
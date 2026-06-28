#!/bin/bash
# 同步上游后运行此脚本，恢复个人定制内容
# 使用方式: bash my-patch.sh

echo "=== 检查 config 是否需要补丁 ==="

if ! grep -q "CONFIG_PACKAGE_shairport-sync=y" config/128muboot.config; then
  echo ">>> 补丁 config/128muboot.config"
  cat >> config/128muboot.config << 'EOF'

# ---------- AirPlay ----------
CONFIG_PACKAGE_shairport-sync=y
CONFIG_PACKAGE_alsa-utils=y
CONFIG_PACKAGE_alsa-lib=y

# ---------- Samba ----------
CONFIG_PACKAGE_samba4-server=y
CONFIG_PACKAGE_samba4-utils=y
CONFIG_PACKAGE_luci-app-samba4=y

# ---------- USB ----------
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-uas=y
CONFIG_PACKAGE_kmod-usb-audio=y
CONFIG_PACKAGE_usbutils=y

# ---------- Filesystem ----------
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-exfat=y
CONFIG_PACKAGE_exfatprogs=y
CONFIG_PACKAGE_kmod-fs-ntfs3=y
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_mount-utils=y

# ---------- LuCI Tools ----------
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_miniupnpd=y

# ---------- Network QoS ----------
CONFIG_PACKAGE_luci-app-sqm=y
CONFIG_PACKAGE_sqm-scripts=y
CONFIG_PACKAGE_tc=y
CONFIG_PACKAGE_kmod-sched-cake=y

# ---------- Useful base tools ----------
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget-ssl=y
# end of Utilities
EOF
  echo ">>> config 补丁完成"
else
  echo ">>> config 已包含自定义包，跳过"
fi

echo "=== 检查 diy-part2.sh ==="
if ! grep -q "shairport 自定义配置" diy-part2.sh; then
  echo ">>> 补丁 diy-part2.sh"
  cat >> diy-part2.sh << 'EOF'

# ====================== shairport 自定义配置 ======================
mkdir -p files/etc/init.d
mkdir -p files/etc/uci-defaults
chmod +x files/etc/init.d/shairport 2>/dev/null || true
chmod +x files/etc/uci-defaults/* 2>/dev/null || true
EOF
  echo ">>> diy-part2.sh 补丁完成"
else
  echo ">>> diy-part2.sh 已包含自定义内容，跳过"
fi

echo "=== 检查 workflow timeout ==="
if grep -q "timeout-minutes: 15" .github/workflows/openwrt-builder.yml; then
  echo ">>> 恢复 timeout 为 60"
  sed -i 's/timeout-minutes: 15/timeout-minutes: 60/' .github/workflows/openwrt-builder.yml
  echo ">>> workflow 补丁完成"
else
  echo ">>> workflow timeout 已是正确值，跳过"
fi

echo ""
echo "✅ 所有补丁检查完毕"
echo "   files/ 目录无需处理（上游不存在此目录，不会被覆盖）"

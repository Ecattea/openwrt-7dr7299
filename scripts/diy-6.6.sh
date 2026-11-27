#!/bin/bash
set -euo pipefail

# Nikki v1.26.2 + Mihomo Meta v1.19.32 (skip mihomo-alpha to keep PROVIDES:=mihomo unambiguous).
rm -rf package/mihomo-meta package/mihomo-alpha package/nikki package/luci-app-nikki /tmp/OpenWrt-nikki
git clone --depth=1 --branch v1.26.2 https://github.com/nikkinikki-org/OpenWrt-nikki.git /tmp/OpenWrt-nikki
cp -a /tmp/OpenWrt-nikki/mihomo-meta package/mihomo-meta
cp -a /tmp/OpenWrt-nikki/nikki package/nikki
cp -a /tmp/OpenWrt-nikki/luci-app-nikki package/luci-app-nikki

# Vantage v1.2.1 LuCI theme & live dashboard (24.10 compatible).
rm -rf package/luci-theme-vantage package/luci-app-vantage /tmp/luci-theme-vantage
git clone --depth=1 --branch v1.2.1 https://github.com/anothaDev/luci-theme-vantage.git /tmp/luci-theme-vantage
cp -a /tmp/luci-theme-vantage/luci-theme-vantage package/luci-theme-vantage
cp -a /tmp/luci-theme-vantage/luci-app-vantage package/luci-app-vantage

# LuCI's current lightweight file manager. Copy only this application.
rm -rf package/luci-app-filemanager /tmp/luci-upstream
git clone --depth=1 https://github.com/openwrt/luci.git /tmp/luci-upstream
cp -a /tmp/luci-upstream/applications/luci-app-filemanager package/luci-app-filemanager

# Device-specific UI polish used by known-good TL-7DR7299 builds.
sed -i '/"mediatek"\/\*|"mvebu"\/\*)/i "mediatek/filogic_a73")\n\tcpu_freq="1.8GHz" ;;' \
  package/emortal/autocore/files/generic/cpuinfo

# Apply minimal WPA3/PMF WTBL group-key, dual-band teardown, and BMC WED/HNAT bypass patches.
mkdir -p package/mtk/drivers/mt_wifi7/patches package/mtk/drivers/mt_hwifi/patches
cp -f "$GITHUB_WORKSPACE/patches/6.6/mt_wifi7/"*.patch package/mtk/drivers/mt_wifi7/patches/
cp -f "$GITHUB_WORKSPACE/patches/6.6/mt_hwifi/"*.patch package/mtk/drivers/mt_hwifi/patches/
ls -la package/mtk/drivers/mt_wifi7/patches/ package/mtk/drivers/mt_hwifi/patches/

# Disable non-stock cpu->wifi PPE pingpong in mtkhnat to avoid sent_ppd WAN black-hole bug.
for p in "$GITHUB_WORKSPACE/patches/6.6/mtk_hnat/"*.patch; do
  [ -f "$p" ] || continue
  patch -p1 -d target/linux/mediatek/files-6.6 < "$p"
done

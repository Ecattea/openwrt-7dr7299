# TP-Link TL-7DR7299 v1 Custom ImmortalWrt Firmware

Built via GitHub Actions from `padavanonly/immortalwrt-mt798x-6.6` (`mt798x-mt799x-6.6-mtwifi`, pinned to commit `6b7374feb`), forked from [huladabang/openwrt-7dr7299](https://github.com/huladabang/openwrt-7dr7299) with minimal proprietary Wi-Fi driver fixes for WPA3/PMF.

## Firmware Details

- **Device**: TP-Link TL-7DR7299 v1
- **SoC**: MediaTek MT7988A (Cortex-A73)
- **Wi-Fi**: MediaTek MT7992 proprietary `mtwifi` driver (`kmod-mt_wifi7` / `kmod-mt_hwifi`)
- **Default LAN IP**: `192.168.6.1`
- **Default user**: `root`
- **Initial password**: empty (set a password immediately after first login)

## Additional Driver Patches (vs. Upstream)

Cherry-picked and verified (0-fuzz against `6b7374feb`) from [padavanonly/immortalwrt-mt798x-6.6#446](https://github.com/padavanonly/immortalwrt-mt798x-6.6/pull/446) (authored by `sKyissKy`), keeping `configs/6.6.txt` untouched to preserve kernel `vermagic` compatibility:

- `patches/6.6/mt_wifi7/980-fix-wtbl-group-key-install.patch`: Fixes `fill_uni_cmd_wtbl_key_info_struc_v2()` in `cmm_sec.c` by converting mutually exclusive `if / else if` branches into independent PTK/GTK, IGTK, and BIGTK blocks, resolving the WPA3/PMF downlink broadcast/multicast drop bug (`keyloc0=8191`, `CIPHER_PGTK=0`).
- `patches/6.6/mt_wifi7/980-110-mt_wifi7-fix-multi-inf-active-cnt-and-teardown-guards.patch`: Counts active MAC adapters from `physical_device_list` so reloading a single band does not prematurely free shared WPA3/OWE global EC tables, and guards transient teardown log errors.
- `patches/6.6/mt_hwifi/070-mt_hwifi-skip-wed-hnat-hook-on-bmc-tx.patch`: Excludes `TK_MGMT_BMC` broadcast/multicast traffic from `wed_hw_tx_allow()` so BMC frames bypass WED/HNAT hardware offload hooks.

## Included Packages

- iStore
- OpenClash (with pre-bundled arm64 Mihomo/Meta core)
- MediaTek TurboACC / HNAT / WED hardware acceleration
- ttyd web terminal
- USB storage & Samba4 file sharing (ext4 / exFAT / NTFS3)
- nlbwmon bandwidth monitor
- UPnP / NAT-PMP
- LuCI file manager
- Tailscale and matching `kmod-tun`
- Maintenance utilities (`openssh-sftp-server`, `htop`, `jq`, etc.)

Omitted: PassWall, Docker, EasyTier, OpenList, DiskMan, and other non-essential packages.

## Build

Open the **Actions** tab, select **Build TL-7DR7299 closed-source Wi-Fi firmware**, and click **Run workflow**.
Successful builds publish both the full `.itb` sysupgrade image and the stripped patched kernel modules (`mt_wifi.ko`, `mtk_hwifi.ko`, and matching `.ipk` packages) to Actions Artifacts and Releases.

## Flashing Notes

- For routine upgrades, only flash the sysupgrade image matching `tplink_tl-7dr7299-v1-squashfs-sysupgrade.itb`.
- Do **not** upload `preloader.bin`, `bl31-uboot.fip`, or images for other devices as sysupgrade firmware.
- Flashing third-party firmware carries bricking risk. Back up your configuration and critical partitions beforehand, and ensure you have a working TL-7DR7299 U-Boot recovery setup.

# Evolution X Device Tree untuk Infinix Smart 20 (X6840)

[![Build](https://github.com/mcfreakky41/evox_device_infinix_X6840/actions/workflows/build.yml/badge.svg)](https://github.com/mcfreakky41/evox_device_infinix_X6840/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Android-16%20(Evolution%20X%20bka)-3ddc84.svg)](https://github.com/Evolution-X)
[![Device](https://img.shields.io/badge/device-Infinix%20X6840-orange.svg)](#️-perangkat)

---

## 🏷️ Tagline

**_Android 16 (API 36) Evolution X ROM build untuk Infinix Smart 20 X6840 dengan MediaTek Helio G81 Ultimate_**

---

## 📱 Perangkat

| Spesifikasi | Nilai |
|-------------|-------|
| **Model** | Infinix Smart 20 (X6840) |
| **SoC** | MediaTek Helio G81 Ultimate (**mt6768**) |
| **Kernel** | 6.6.x (prebuilt dari dump stok) |
| **Target Android** | **16** (Evolution X `bka`) |
| **Arsitektur** | arm64-v8a (64-bit only) |
| **Partisi** | A/B + dynamic (`super`) + `vendor_boot` |
| **Codename vendor** | `tssi` |
| **Build Fingerprint** | `Infinix/X6840-OP/Infinix-X6840:16/BP2A.250605.031.A3/301400019:user/release-keys` |

> **Catatan penting:** Vendor blobs hanya untuk referensi. Saat flash, gunakan device tree yang sudah diperbaiki sehingga fstab dan AVB flags tetap konsisten.

---

## 📂 Struktur Repositori

```
device/infinix/X6840/        # Device tree utama
├── AndroidProducts.mk       # Product makefiles
├── BoardConfig.mk           # Board configuration
├── device.mk                # Device-specific product configuration
├── evolution_X6840.mk       # Main product makefile (Evolution X)
├── vendorsetup.sh           # Lunch combo setup
├── prebuilt/                # Prebuilt kernel (Image)
├── rootdir/                 # Root filesystems, fstab
│   └── etc/fstab.mt6768     # Filesystem table (EROFS + AVB fixes)
├── sepolicy/                # SELinux policies
│   └── vendor/mtk.te        # MediaTek vendor SELinux
vendor/infinix/X6840/        # Vendor tree
├── X6840-vendor.mk          # Vendor product makefile
└── proprietary/             # Symlink placeholder (blobs diunduh terpisah)
.github/workflows/           # CI/CD
├── build.yml                # GitHub Actions workflow
scripts/                     # Utilitas build
├── fetch-blobs.sh           # Fetch vendor blobs (local build)
docs/                        # Dokumentasi
├── FLASHING.md              # Panduan flash ROM lengkap
```

> **Catatan:** Blob vendor tidak disimpan di git (ratusan MB). Diunduh otomatis via Release `blobs-v1` dari repo PixelOS device tree (device yang sama).

---

## 🏗️ Build

### Otomatis (Cara Utama - GitHub Actions)

Build berjalan di **GitHub Actions** pada runner `ubuntu-24.04-arm` (ARM64 native):

```bash
gh workflow run build.yml -R mcfreakky41/evox_device_infinix_X6840
```

Atau lewat UI:
1. Buka tab **Actions** → pilih **build.yml**
2. Klik **Run workflow**
3. Pilih `evox_branch` (default: `bka`) dan `build_type` (userdebug / user / eng)
4. Klik **Run workflow**

> **💾 Catatan Disk:** Workflow otomatis membebaskan disk sebelum sync, membuang project x86/emulator/test yang tidak dipakai build ARM64, menghapus `.repo` setelah sync, dan membangun **image-only** (`systemimage systemextimage productimage vendorimage vbmetaimage vbmeta_systemimage vbmeta_vendorimage`) — bukan `bacon`. Ini mencegah error `No space left on device` pada runner 145 GB.

### Lokal (Tidak Disarankan untuk Spec Rendah)

```bash
# 1. Sinkron source Evolution X
mkdir -p ~/android/evox && cd ~/android/evox
repo init -u https://github.com/Evolution-X/manifest -b bka --depth=1
repo sync -c -j$(nproc --all)

# 2. Tempatkan device tree + vendor tree dari repo ini ke source tree
git clone https://github.com/mcfreakky41/evox_device_infinix_X6840 /tmp/x6840-tree
mkdir -p device/infinix vendor/infinix
cp -r /tmp/x6840-tree/device/infinix/X6840 device/infinix/X6840
cp -r /tmp/x6840-tree/vendor/infinix/X6840 vendor/infinix/X6840

# 3. Fetch + verifikasi vendor blobs (wajib cocok dengan SHA256SUMS)
bash /tmp/x6840-tree/scripts/fetch-blobs.sh vendor/infinix/X6840/proprietary

# 4. Build (image-only, cukup untuk flashing system/system_ext/product/vendor/vbmeta)
source build/envsetup.sh
lunch evolution_X6840-bp4a-userdebug
mka systemimage systemextimage productimage vendorimage vbmetaimage vbmeta_systemimage vbmeta_vendorimage -j$(nproc --all)
```

---

## ⚡ Flash

### Prosedur singkat

> **Belum diuji pada perangkat fisik dengan image hasil build ini.** Backup
> dulu (lewat ADB saat Android masih boot), baru masuk fastbootd. Urutan
> lengkap + rollback ada di [`docs/FLASHING.md`](docs/FLASHING.md).

```bash
# Backup dilakukan SEBELUM reboot (lihat docs/FLASHING.md)
adb reboot fastboot
fastboot getvar is-userspace    # harus: yes (fastbootd)

fastboot flash system      system.img
fastboot flash system_ext  system_ext.img
fastboot flash product     product.img
fastboot flash vendor      vendor.img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot flash vbmeta_system vbmeta_system.img
fastboot flash vbmeta_vendor vbmeta_vendor.img
fastboot erase userdata
fastboot reboot
```

### Yang Tidak Boleh Diflash

❌ **Jangan flash `super.img`** — build ini tidak membuatnya  
❌ `boot`, `vendor_boot`, `init_boot`, `dtbo` tetap stok (kernel prebuilt hanya untuk build)

---

## 📚 Dokumentasi

| File | Deskripsi |
|------|-----------|
| `README.md` | Panduan utama project |
| `docs/FLASHING.md` | Panduan flash ROM lengkap |
| `scripts/fetch-blobs.sh` | Script fetch vendor blobs (build lokal) |

---

## 🐛 Laporkan Bug

Gunakan [Issue Template](.github/ISSUE_TEMPLATE/bug_report.yml) dengan:

1. Build number (misal: run #5)
2. Log build error
3. Output `git log --oneline -10`
4. `lunch` target yang dipakai

---

## 📄 Lisensi

- **Kode proyek:** [Apache License 2.0](LICENSE)
- **Blob vendor:** Proprietary (Transsion/MediaTek) - tidak termasuk di Apache-2.0

---

## 🙏 Kredit

- **[AOSP](https://source.android.com)**
- **[Evolution X](https://github.com/Evolution-X)**
- **[LineageOS](https://github.com/LineageOS)**
- **[PixelOS](https://github.com/PixelOS-AOSP)** — vendor blobs (same device)
- **rama-firmware-dumps** — referensi device kembar X6728
- **[Building AOSP on ARM64](https://actinis.io/blog/building-aosp-on-arm64)** — referensi patch build host ARM64
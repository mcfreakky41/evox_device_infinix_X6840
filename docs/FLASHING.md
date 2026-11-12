# Panduan Flash Evolution X untuk Infinix Smart 20 (X6840)

> **⚠️ PERINGATAN:** Flash custom ROM bisa meng-*brick* perangkat. Lakukan dengan risiko sendiri. Pastikan sudah paham risikonya dan punya backup penuh sebelum memulai.

---

## 📋 Persyaratan

- **PC** dengan `adb` dan `fastboot` terinstall
- **Kabel USB** berkualitas baik (data + charge)
- **Baterai** minimal 50% (disarankan 80%+)
- **OEM Unlock** sudah aktif di Developer Options
- **Bootloader** sudah unlocked
- **Root access** (Magisk/KernelSU) untuk backup partisi

---

## 💾 Backup Sebelum Flash (WAJIB)

Lakukan **SEBELUM** reboot ke fastboot:

```bash
# 1. Cek slot aktif
fastboot getvar current-slot
# Output: current-slot: a (atau b)
# Simpan nilai ini sebagai SLOT

# 2. Backup partisi penting ke internal storage
# Ganti _a dengan _b jika slot aktif adalah b
SLOT="_a"  # atau "_b" sesuai output di atas

adb shell su -c "dd if=/dev/block/by-name/boot${SLOT} of=/sdcard/boot${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/init_boot${SLOT} of=/sdcard/init_boot${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/vendor_boot${SLOT} of=/sdcard/vendor_boot${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/dtbo${SLOT} of=/sdcard/dtbo${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta${SLOT} of=/sdcard/vbmeta${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta_system${SLOT} of=/sdcard/vbmeta_system${SLOT}.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta_vendor${SLOT} of=/sdcard/vbmeta_vendor${SLOT}.img"

# 3. Backup super partitions (opsional tapi direkomendasikan - butuh ruang ~9GB)
adb shell su -c "dd if=/dev/block/by-name/super of=/sdcard/super.img"

# 4. Pull ke PC
adb pull /sdcard/boot${SLOT}.img .
adb pull /sdcard/init_boot${SLOT}.img .
adb pull /sdcard/vendor_boot${SLOT}.img .
adb pull /sdcard/dtbo${SLOT}.img .
adb pull /sdcard/vbmeta${SLOT}.img .
adb pull /sdcard/vbmeta_system${SLOT}.img .
adb pull /sdcard/vbmeta_vendor${SLOT}.img .
# adb pull /sdcard/super.img .  # opsional, file besar

# 5. Backup data pribadi (foto, kontak, dll)
# Gunakan Google Backup, Swift Backup, atau manual copy ke PC
```

> **Catatan:** Semua perintah backup memerlukan akses root (`su`). Pastikan Magisk/KernelSU sudah terinstall dan berfungsi.

---

## 🔧 Flash ROM

### 1. Masuk Fastbootd

```bash
adb reboot fastboot
# Tunggu sampai layar menunjukkan "FastbootD" atau logo fastboot

# Verifikasi
fastboot getvar is-userspace
# Harus output: "yes"
```

### 2. Flash Image

```bash
# Flash partisi sistem (image-only build dengan EROFS)
fastboot flash system      system.img
fastboot flash system_ext  system_ext.img
fastboot flash product     product.img
fastboot flash vendor      vendor.img

# Flash vbmeta chain (disable verity untuk custom ROM)
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot flash vbmeta_system vbmeta_system.img
fastboot flash vbmeta_vendor vbmeta_vendor.img
```

### 3. Wipe Data

```bash
# WAJIB: wipe userdata agar bootloop tidak terjadi
fastboot erase userdata
```

### 4. Reboot

```bash
fastboot reboot
```

---

## 🔄 Rollback ke Stok (Jika Gagal)

Jika bootloop atau error, restore backup stok:

```bash
# Masuk fastbootd
adb reboot fastboot  # atau dari mati: power + vol up

# Restore partisi kritis (ganti _a/_b sesuai slot backup)
SLOT="_a"

fastboot flash boot      boot${SLOT}.img
fastboot flash init_boot init_boot${SLOT}.img
fastboot flash vendor_boot vendor_boot${SLOT}.img
fastboot flash dtbo      dtbo${SLOT}.img
fastboot flash vbmeta    vbmeta${SLOT}.img
fastboot flash vbmeta_system vbmeta_system${SLOT}.img
fastboot flash vbmeta_vendor vbmeta_vendor${SLOT}.img

# Opsional: restore super.img (butuh waktu lama, ~9GB)
# fastboot flash super super.img

# Wipe data
fastboot erase userdata

fastboot reboot
```

---

## ❌ Yang TIDAK Boleh Diflash

| Partisi | Alasan |
|---------|--------|
| `boot`, `init_boot`, `vendor_boot`, `dtbo` | Tetap gunakan stok. Kernel prebuilt kita hanya untuk build, bukan untuk flash. |
| `super.img` | Build ini **tidak membuat** super.img. Flash-nya akan *brick* perangkat. Partisi logis di-flash individual. |

---

## 🐛 Troubleshooting

### Fastboot tidak detect device
```bash
# Cek driver
lsusb | grep -i google
# Install driver USB (Linux: udev rules, Windows: Google USB Driver)

# Coba port/kabel lain
```

### "Partition doesn't exist" saat erase
```bash
# Normal untuk partisi cache yang tidak ada di device ini
fastboot erase cache  # Error "Partition doesn't exist" = OK, lanjut
```

### Bootloop setelah flash
1. Pastikan `fastboot erase userdata` sudah dijalankan
2. Coba flash ulang semua vbmeta dengan `--disable-verity --disable-verification`
3. Restore backup stok (lihat bagian Rollback)

### "Remote: Flash Write Failure"
- Disk runner penuh / timeout → coba ulangi flash per partisi
- Kabel USB bermasalah → ganti kabel/port

---

## 📝 Catatan Penting

1. **Slot A/B**: Device ini pakai Virtual A/B. Slot aktif = `_a` atau `_b`. Flash ke slot yang aktif (`fastboot getvar current-slot`).
2. **Dynamic Partitions**: `system`, `system_ext`, `product`, `vendor` adalah partisi logis di dalam `super`. Flash otomatis resize.
3. **Filesystem EROFS**: Build ini menggunakan EROFS (bukan ext4) sesuai stock firmware. Fastboot otomatis handle.
4. **AVB/VBMeta Chain**: Custom ROM ditandatangani test key. Harus disable verity saat flash vbmeta. Flash juga vbmeta_system & vbmeta_vendor.
5. **Vendor Stok**: Build ini mem-build vendor.img baru (dari blob stock). Jika bootloop, coba flash vendor stock.
6. **GSI vs Device-Specific**: Build ini device-specific (bukan GSI). Flash partisi logis individual.

---

## 📞 Bantuan

- [Evolution X Telegram](https://t.me/EvolutionXOfficial)
- [Infinix Smart 20 XDA Thread](https://xdaforums.com/f/infinix-smart-20.12345/)
- GitHub Issues: [evox_device_infinix_X6840](https://github.com/mcfreakky41/evox_device_infinix_X6840/issues)
# Panduan Flash Evolution X untuk Infinix Smart 20 (X6840)

> **⚠️ PERINGATAN:** Flash custom ROM bisa meng-*brick* perangkat. Lakukan dengan risiko sendiri. Pastikan sudah paham risikonya dan punya backup penuh sebelum memulai.

---

## 📋 Persyaratan

- **PC** dengan `adb` dan `fastboot` terinstall
- **Kabel USB** berkualitas baik (data + charge)
- **Baterai** minimal 50% (disarankan 80%+)
- **OEM Unlock** sudah aktif di Developer Options
- **Bootloader** sudah unlocked

---

## 💾 Backup Sebelum Flash (WAJIB)

Lakukan **SEBELUM** reboot ke fastboot:

```bash
# 1. Backup partisi penting ke PC
adb shell su -c "dd if=/dev/block/by-name/boot_a of=/sdcard/boot_a.img"
adb shell su -c "dd if=/dev/block/by-name/init_boot_a of=/sdcard/init_boot_a.img"
adb shell su -c "dd if=/dev/block/by-name/vendor_boot_a of=/sdcard/vendor_boot_a.img"
adb shell su -c "dd if=/dev/block/by-name/dtbo_a of=/sdcard/dtbo_a.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta_a of=/sdcard/vbmeta_a.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta_system_a of=/sdcard/vbmeta_system_a.img"
adb shell su -c "dd if=/dev/block/by-name/vbmeta_vendor_a of=/sdcard/vbmeta_vendor_a.img"

# 2. Pull ke PC
adb pull /sdcard/boot_a.img .
adb pull /sdcard/init_boot_a.img .
adb pull /sdcard/vendor_boot_a.img .
adb pull /sdcard/dtbo_a.img .
adb pull /sdcard/vbmeta_a.img .
adb pull /sdcard/vbmeta_system_a.img .
adb pull /sdcard/vbmeta_vendor_a.img .

# 3. Backup data pribadi (foto, kontak, dll)
# Gunakan Google Backup, Swift Backup, atau manual copy ke PC
```

> **Catatan:** Slot aktif saat ini adalah `_a` (verifikasi: `fastboot getvar current-slot`)

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
# Flash partisi sistem (image-only build)
fastboot flash system      system.img
fastboot flash system_ext  system_ext.img
fastboot flash product     product.img

# Flash vbmeta (disable verity untuk custom ROM)
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
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

# Restore partisi kritis
fastboot flash boot      boot_a.img
fastboot flash init_boot init_boot_a.img
fastboot flash vendor_boot vendor_boot_a.img
fastboot flash dtbo      dtbo_a.img
fastboot flash vbmeta    vbmeta_a.img
fastboot flash vbmeta_system vbmeta_system_a.img
fastboot flash vbmeta_vendor vbmeta_vendor_a.img

# Wipe data
fastboot erase userdata

fastboot reboot
```

---

## ❌ Yang TIDAK Boleh Diflash

| Partisi | Alasan |
|---------|--------|
| `super.img` | Build ini **tidak membuat** super.img. Flash-nya akan *brick* perangkat. |
| `boot`, `vendor_boot`, `init_boot`, `dtbo` | Tetap gunakan stok. Kernel prebuilt kita hanya untuk build, tidak untuk flash. |
| `vendor`, `odm`, `vendor_dlkm`, `odm_dlkm` | Vendor blobs dibangun ulang tapi **belum tervalidasi** di perangkat. Tetap pakai stok. |
| `vbmeta_system.img`, `vbmeta_vendor.img` | Hanya untuk inspeksi. Vendor stok sudah punya vbmeta sendiri. |

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
2. Coba flash ulang `vbmeta.img` dengan `--disable-verity --disable-verification`
3. Restore backup stok (lihat bagian Rollback)

### "Remote: Flash Write Failure"
- Disk runner penuh / timeout → coba ulangi flash per partisi
- Kabel USB bermasalah → ganti kabel/port

---

## 📝 Catatan Penting

1. **Slot A/B**: Device ini pakai Virtual A/B. Slot aktif = `_a`. Flash ke slot yang aktif.
2. **Dynamic Partitions**: `system`, `system_ext`, `product` adalah partisi logis di dalam `super`. Flash otomatis resize.
3. **AVB/VBMeta**: Custom ROM ditandatangani test key. Harus disable verity saat flash vbmeta.
4. **Vendor Stok**: Vendor/ODM/DLKM tetap stok. Jangan diganti kecuali sudah tervalidasi.
5. **GSI vs Device-Specific**: Build ini device-specific (bukan GSI). Flash partisi logis, bukan system.img GSI.

---

## 📞 Bantuan

- [Evolution X Telegram](https://t.me/EvolutionXOfficial)
- [Infinix Smart 20 XDA Thread](https://xdaforums.com/f/infinix-smart-20.12345/)
- GitHub Issues: [evox_device_infinix_X6840](https://github.com/mcfreakky41/evox_device_infinix_X6840/issues)
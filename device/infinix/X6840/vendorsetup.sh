#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# CATATAN: add_lunch_combo sudah OBSOLETE di AOSP modern.
# Lunch combo kini diambil dari COMMON_LUNCH_CHOICES di AndroidProducts.mk.
# File ini sengaja dibiarkan (kompatibilitas) tetapi tidak menambahkan apa pun.
#
# PENTING soal cara lunch:
#   nama product 'evolution_X6840' memakai underscore. Format legacy
#   'product-variant' di-parse dengan delimiter '-' sehingga variant jadi
#   kosong -> error "Invalid lunch combo".
#   Gunakan format baru: lunch evolution_X6840-bp4a-userdebug
#
# PENTING soal RELEASE config:
#   Evolution X (branch bka, Android 16) pakai release config 'bp4a'
#   (lihat build/release/lineage_release_config.mk -> declare-release-config).
#   'bp4a' juga cocok dgn fingerprint build vendor device kita:
#   Infinix/X6840-OP/Infinix-X6840:16/BP2A.250605.031.A3/...
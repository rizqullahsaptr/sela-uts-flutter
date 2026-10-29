# Catatan Verifikasi — Sela

Dokumen ini mencatat apa yang benar-benar dijalankan, dengan keluaran apa
adanya. Tidak ada hasil yang dikarang.

Lingkungan:

| Butir | Nilai |
|---|---|
| Sistem operasi | Windows 10 (10.0.19045) |
| Flutter | 3.47.1 stable, revisi 6655482ec0 |
| Dart | 3.13.1 |
| Perangkat yang tersedia | Windows desktop, Chrome, Edge |
| Emulator Android | `Small_Phone` (Android 16, x86_64), sempat berjalan tetapi tidak stabil |
| Perangkat Android fisik | Tidak terhubung |

## 1. Formatter

```text
$ dart format lib test
Formatted 15 files (0 changed) in 0.27 seconds.
```

## 2. Analyzer

```text
$ flutter analyze
Analyzing UTS...
No issues found! (ran in 46.9s)
```

`dart analyze` juga dijalankan lebih awal dan hasilnya sama, tanpa issue.

## 3. Pengujian otomatis

```text
$ flutter test
00:18 +45: All tests passed!
```

Empat puluh lima pengujian, terbagi dalam tiga berkas:

| Berkas | Cakupan |
|---|---|
| `test/place_test.dart` | Pemetaan JSON ke model, nilai hilang/salah tipe, format biaya, pencarian, alasan rekomendasi |
| `test/place_repository_test.dart` | Pembacaan aset, aset gagal, JSON rusak, struktur salah, daftar kosong, filter DAN, pengurutan, reset, toggle chip |
| `test/app_test.dart` | Navigasi beranda → daftar → detail, kembali dengan filter utuh, keadaan kosong, pengurutan, overflow pada 320×568 dan 1024×768 dengan teks 1,3–1,6× |

## 4. Build web

```text
$ flutter build web --release
Compiling lib\main.dart for the Web...  188.8s
√ Built build\web
```

Build ini menghasilkan `build/web` berukuran sekitar 37 MB dan dipakai untuk
menjalankan aplikasi pada pemeriksaan visual. Folder `build/` tidak disertakan
ke repository (lihat `.gitignore`).

## 5. Pemeriksaan aplikasi berjalan

Aplikasi dijalankan dari build web melalui server lokal, lalu dikendalikan
lewat Chrome DevTools Protocol pada lebar 390 px (ponsel) dan 1024 px (lebar).
Screenshot disimpan di `docs/screenshots/`.

Yang diamati pada aplikasi berjalan:

| Pemeriksaan | Hasil yang terlihat |
|---|---|
| Beranda menampilkan tiga rekomendasi | Ya, dengan alasan yang berasal dari atribut tempat |
| "Lihat semua" membuka daftar | Ya, 8 tempat ditemukan |
| Filter "Diskusi kelompok" + "Meja besar" | 5 tempat ditemukan, kedua chip berwarna hijau tua |
| Pengurutan "Biaya terendah" | Tempat gratis tampil lebih dulu |
| Memilih kartu membuka detail yang benar | Ya, nama, alamat, biaya, dan kecocokan aktivitas sesuai kartu |
| Kembali dari detail | Daftar kembali dengan 5 hasil dan filter masih terpasang |
| Kata kunci "zzz" | "Belum ada tempat yang cocok" beserta tombol hapus filter |
| Layar 1024 px | Grid dua kolom dengan foto di atas, konten berlebar maksimum |

Berkas bukti:

| Berkas | Isi |
|---|---|
| `docs/screenshots/01_beranda.png` | Beranda |
| `docs/screenshots/02_daftar.png` | Daftar penuh |
| `docs/screenshots/03_daftar_filter.png` | Filter dan pengurutan aktif |
| `docs/screenshots/04_detail.png` | Detail lengkap |
| `docs/screenshots/05_hasil_kosong.png` | Keadaan kosong |
| `docs/screenshots/06_daftar_lebar.png` | Layar lebar |

Screenshot diambil dari versi web, bukan dari perangkat Android. Lebar 390 px
dipakai untuk meniru layar ponsel, dan tinggi jendela diperpanjang pada
screenshot detail agar seluruh halaman terlihat dalam satu gambar.

## 6. Pemeriksaan data

```text
8 tempat, id unik, seluruh field wajib ada, semua imageAsset ditemukan
Area: Dinoyo, Ijen, Klojen, Lowokwaru, Merjosari, Sigura-gura, Soekarno Hatta, Tlogomas
Suasana: fokus, diskusi
Fasilitas: ac, kopi, meja_besar, parkir, ruang_tenang, stopkontak, wifi
Kisaran biaya: 0–10.000 sampai 25.000–50.000
```

## 7. Android

```text
$ flutter build apk --debug
√ Built build\app\outputs\flutter-apk\app-debug.apk   (152,581,841 bytes)
```

APK berhasil dibuat, dipasang ke emulator `Small_Phone` melalui
`adb install -r`, dan aplikasi terbuka menampilkan halaman beranda Sela.
Namun emulator pada mesin pengembangan tidak stabil: System UI berhenti
merespons, waktu buka aplikasi sangat lama (sekitar 61 detik), dan tangkapan
layar dari emulator tidak dapat diandalkan. Karena itu:

- Build APK **berhasil** dan dapat dilaporkan sebagai hasil kompilasi.
- Aplikasi **pernah tampil** di emulator, tetapi tidak dipakai sebagai bukti
  visual pada laporan.
- Screenshot Android **belum tersedia** dan harus diambil di perangkat atau
  emulator yang stabil.
- Pengujian alur lengkap di Android **belum** dilakukan.

Folder `build/` dan APK tidak disertakan pada paket source.

## 8. Yang belum diverifikasi

| Butir | Alasan |
|---|---|
| Pengujian alur di perangkat Android | Emulator tidak stabil; belum ada perangkat fisik |
| Screenshot Android | Menunggu perangkat/emulator yang stabil |
| Menjalankan pada iOS | Lingkungan Windows tidak mendukung build iOS |
| Pengujian pengguna | Belum ada pengguna yang menguji aplikasi |
| Pengukuran performa | Tidak diukur; laporan tidak menyatakan klaim performa |
| Pemeriksaan pada pembaca layar nyata | Semantics dipakai pada widget utama, tetapi belum diuji dengan TalkBack/VoiceOver |

# Sela — Panduan Tempat Belajar

Sela adalah aplikasi Flutter untuk membantu mahasiswa memilih tempat belajar
berdasarkan suasana, fasilitas, dan kisaran biaya. Aplikasi menjawab tiga
pertanyaan utama: tempat ini cocok untuk aktivitas apa, fasilitasnya apa, dan
berapa kisaran biayanya.

Proyek ini dibuat untuk UTS Mobile Programming Practicum.

- Nama: Muhammad Rizqullah Saputra
- NIM: 240605110102
- Kelas praktikum: E
- Repository praktikum asal: https://github.com/rizqullahsaptr/Mobile-Programming-Practicum

## Halaman dan Fungsi

| Halaman | Berkas | Fungsi |
|---|---|---|
| Beranda | `lib/pages/home_page.dart` | Identitas Sela, pencarian nama/area, pilihan kebutuhan, tiga rekomendasi beserta alasan |
| Daftar tempat | `lib/pages/places_page.dart` | Pencarian, filter suasana dan fasilitas, pengurutan, jumlah hasil, kartu tempat, keadaan kosong |
| Detail tempat | `lib/pages/place_detail_page.dart` | Foto, nama, area, alamat contoh, jam operasional, biaya, suasana, deskripsi, kecocokan aktivitas, fasilitas |

Alur utama: beranda → daftar (dengan kata kunci atau filter yang sudah
terpasang) → detail → kembali ke daftar dengan keadaan filter tetap utuh.

## Fitur yang Berjalan

- Pencarian nama, area, dan alamat contoh pada beranda dan halaman daftar.
- Chip kebutuhan "Fokus sendiri" dan "Diskusi kelompok" yang langsung membuka
  daftar dengan filter terpasang.
- Filter fasilitas yang dapat dikombinasikan: Wi-Fi, stopkontak, ruang tenang,
  meja besar.
- Pengurutan Rekomendasi, Nama A–Z, dan Biaya terendah.
- Keadaan hasil kosong dengan penjelasan dan tombol "Hapus filter".
- Keadaan data gagal dimuat dengan tombol "Coba lagi".
- Navigasi kembali dari detail mempertahankan kata kunci dan filter daftar.
- Tata letak responsif: satu kolom pada ponsel, grid dua kolom pada layar lebar.
- Catatan "data contoh untuk praktikum" pada setiap halaman yang menampilkan data.

Tidak ada login, pembayaran, reservasi, geolokasi, peta, atau backend. Tombol
yang tampil semuanya berfungsi.

## Struktur Proyek

```text
UTS/
  android/                     # konfigurasi Android
  ios/                         # konfigurasi iOS
  web/                         # konfigurasi versi web
  windows/                     # konfigurasi desktop (opsional)
  lib/
    main.dart                  # runApp
    app.dart                   # MaterialApp, pemuatan data, keadaan memuat/gagal
    theme/app_theme.dart       # warna, tipografi, jarak, gaya komponen
    models/place.dart          # model Place + format biaya + pencarian
    models/facility.dart       # enum StudyMode dan katalog fasilitas
    data/place_repository.dart # pembacaan JSON, PlaceQuery (filter + urutan)
    pages/home_page.dart
    pages/places_page.dart
    pages/place_detail_page.dart
    widgets/place_card.dart    # kartu tempat dan gambar dengan fallback
    widgets/filter_chips.dart  # chip suasana/fasilitas, catatan data, keadaan gagal
    widgets/search_field.dart
  assets/
    data/places.json           # 8 tempat fiktif
    images/                    # 8 foto ilustrasi
    fonts/                     # Newsreader dan Inter
  test/
    place_test.dart
    place_repository_test.dart
    app_test.dart
  docs/
    design/01_beranda.svg
    design/02_daftar.svg
    design/03_detail.svg
    UI_DESIGN.md
    ASSET_SOURCES.md
    PANDUAN_LAPORAN.md
    PANDUAN_LIVE_CODING.md
    VERIFIKASI.md
    screenshots/
  pubspec.yaml
  pubspec.lock
  analysis_options.yaml
  .gitignore
  README.md
```

## Sumber Data

Data berasal dari `assets/data/places.json` berisi 8 tempat fiktif dengan field
`id`, `name`, `area`, `address`, `description`, `atmosphere`, `studyModes`,
`modeNotes`, `facilities`, `priceMin`, `priceMax`, `openingHours`, dan
`imageAsset`.

Pembacaan data dipusatkan di `PlaceRepository` (`lib/data/place_repository.dart`).
Widget hanya mengenal objek `Place`, sehingga penggantian sumber lokal menjadi
API cukup mengubah isi `load()` tanpa menulis ulang halaman.

Seluruh nama tempat, alamat, harga, dan jam operasional adalah contoh. Foto
merupakan ilustrasi berlisensi, bukan foto tempat nyata. Rincian ada di
`docs/ASSET_SOURCES.md`.

## Kebutuhan Lingkungan

Versi yang benar-benar dipakai saat pengembangan dan pemeriksaan:

| Perangkat lunak | Versi |
|---|---|
| Flutter | 3.47.1 stable (revisi `6655482ec0`) |
| Dart | 3.13.1 |
| Sistem operasi pengembangan | Windows 10 |

Proyek ini sebelumnya diverifikasi menggunakan Flutter 3.47.1 dan Dart 3.13.1. Gunakan versi tersebut untuk mereproduksi lingkungan pemeriksaan. `pubspec.yaml` mensyaratkan Dart >=3.13.1 dan <4.0.0. Kompatibilitas dengan versi Flutter dan Dart yang lebih lama belum diverifikasi; jangan menurunkan batas SDK tanpa menyesuaikan kode dan dependency serta menjalankan ulang analyzer dan tes.

Yang perlu dipasang di laptop lain:

- Flutter SDK (stable) beserta Dart yang menyertainya
- Android SDK + `platform-tools` (untuk menjalankan di emulator atau ponsel)
- Android Studio atau VS Code dengan ekstensi Flutter
- Perangkat Android dengan USB debugging, emulator Android, atau Chrome untuk
  menjalankan versi web

Tidak memerlukan koneksi internet setelah `flutter pub get` selesai: font,
gambar, dan JSON dibundel sebagai aset.

## Menjalankan di Laptop Lain

1. **Pasang Flutter dan Android SDK yang kompatibel.**

   ```bash
   flutter --version
   flutter doctor
   ```

   Pastikan bagian Flutter dan Android toolchain bertanda centang. Bila ada
   tanda silang pada Android licenses, jalankan `flutter doctor --android-licenses`.

2. **Clone repository ini dan buka folder proyeknya.**

   ```bash
   git clone https://github.com/rizqullahsaptr/sela-uts-flutter.git
   cd sela-uts-flutter
   ```

   Folder yang dibuka harus folder yang berisi `pubspec.yaml`, bukan folder
   induknya.

3. **Pasang dependency.**

   ```bash
   flutter pub get
   ```

4. **Periksa perangkat yang tersedia.**

   ```bash
   flutter devices
   ```

   Perintah ini menampilkan daftar perangkat beserta `device-id`-nya, misalnya
   `emulator-5554`, `chrome`, atau kode perangkat fisik.

5. **Jalankan aplikasi.**

   ```bash
   flutter run -d <device-id>
   ```

   Contoh: `flutter run -d emulator-5554` atau `flutter run -d chrome`.

Bila Android SDK sudah terpasang tetapi tidak terdeteksi, jalankan
`flutter config --android-sdk <lokasi-sdk>` pada laptop tersebut. Lokasi SDK
tidak disertakan di proyek ini dan memang tidak boleh ikut, karena bergantung
pada tiap komputer.

Menjalankan pengujian dan pemeriksaan kode:

```bash
flutter analyze
flutter test
```

## Status Verifikasi Aktual

Yang benar-benar dijalankan pada lingkungan pengembangan:

| Pemeriksaan | Hasil |
|---|---|
| `dart format lib test` | 15 berkas, tidak ada perubahan |
| `flutter analyze` | `No issues found!` |
| `flutter test` | 45 pengujian lulus |
| Pemuatan JSON ke model | Diuji otomatis, termasuk JSON rusak dan aset hilang |
| Pencarian, kombinasi filter, reset, pengurutan | Diuji otomatis |
| Pemilihan kartu membuka detail yang benar | Diuji otomatis |
| Kembali dari detail mempertahankan kata kunci dan filter | Diuji otomatis |
| Tampilan tanpa overflow pada 320×568 dan 1024×768 dengan teks diperbesar | Diuji otomatis |
| Aplikasi dijalankan dan diperiksa secara visual | Versi web (Chrome), screenshot di `docs/screenshots/` |
| `flutter build apk --debug` | Berhasil menghasilkan `app-debug.apk` |
| Aplikasi berjalan di emulator Android | Terpasang dan tampil, tetapi emulator tidak stabil pada mesin pengembangan sehingga **tidak** dipakai sebagai bukti visual |

Yang **belum** dilakukan dan tidak diklaim: pengujian pada perangkat Android
fisik, pengujian di iOS, pengujian pengguna, dan pengukuran performa.

Screenshot di `docs/screenshots/` berasal dari versi web aplikasi yang
benar-benar dijalankan (lebar 390 px untuk tampilan ponsel dan 1024 px untuk
layar lebar), bukan mockup. Rincian ada di `docs/VERIFIKASI.md`.

## Dokumentasi Pendukung

- `docs/UI_DESIGN.md` — keputusan warna, tipografi, jarak, layout, dan perubahan
  dari rancangan awal
- `docs/design/` — wireframe ketiga halaman sebagai rancangan awal
- `docs/ASSET_SOURCES.md` — sumber, pemilik, dan lisensi font serta foto
- `docs/PANDUAN_LAPORAN.md` — kerangka enam bagian laporan beserta bahan dan
  lokasi cuplikan kode
- `docs/PANDUAN_LIVE_CODING.md` — urutan demonstrasi dan satu perubahan kecil
  yang bisa dipraktikkan

# Panduan Live Coding — Sela

Urutan demonstrasi 8–12 menit. Setiap bagian menyebut berkas dan fungsi yang
benar-benar ada di proyek, agar kamu dapat menjelaskan alur kode, bukan
menghafal.

Sebelum mulai: jalankan `flutter run -d chrome` (atau perangkat Android), dan
buka `UTS/` di editor dengan panel file terlihat.

## 1. Pembuka (1 menit)

Sebutkan masalah dan solusinya dalam dua kalimat:

> Mahasiswa perlu memilih tempat belajar, tetapi informasi tentang suasana,
> fasilitas, dan biaya tersebar. Sela mengumpulkan ketiganya dalam satu alur:
> cari, saring, pilih, lihat detail.

Tunjukkan tiga halaman dengan mengklik cepat: beranda → daftar → detail →
kembali.

## 2. Struktur berkas (1 menit)

Buka panel `lib/` dan sebutkan pembagiannya:

- `main.dart` — hanya menjalankan aplikasi
- `app.dart` — `MaterialApp`, pemuatan data, keadaan memuat/gagal
- `models/` — bentuk data
- `data/` — pembacaan data dan logika filter
- `pages/` — tiga halaman
- `widgets/` — komponen yang dipakai berulang
- `theme/` — warna, tipografi, jarak

Kalimat kunci: "Halaman tidak membaca JSON sendiri. Semua lewat satu
repository."

## 3. Model dan JSON (2 menit)

1. Buka `assets/data/places.json`, tunjukkan satu objek tempat.
2. Buka `lib/models/place.dart`, tunjukkan `Place.fromJson` (baris 41).
3. Jelaskan tiga hal:
   - setiap field dipetakan ke properti `final`;
   - `studyModes` diubah dari teks JSON menjadi `enum StudyMode`;
   - nilai yang hilang atau salah tipe diberi nilai aman, bukan dibiarkan
     menyebabkan crash.
4. Tunjukkan `priceLabel` (baris 99) sebagai contoh format tampilan yang
   berasal dari data, bukan ditulis manual di widget.

## 4. Pemuatan data (1 menit)

Buka `lib/app.dart`. Jelaskan `FutureBuilder`:

- `ConnectionState.waiting` → indikator memuat
- `snapshot.hasError` → tampilan gagal dengan tombol "Coba lagi"
- berhasil → `HomePage` menerima daftar tempat

Tunjukkan `PlaceRepository.load()` di `lib/data/place_repository.dart` baris 41,
lalu sebutkan bahwa mengganti isi method itu menjadi permintaan HTTP tidak
mengubah halaman mana pun.

## 5. Daftar dan filter (3 menit)

1. Buka `lib/pages/places_page.dart`, tunjukkan `_query` dan `_update` (baris 50).
2. Buka `lib/data/place_repository.dart`, tunjukkan `PlaceQuery` (baris 93) dan
   `apply` (baris 144).
3. Jelaskan logika di `apply`:
   - pencarian memeriksa nama, area, dan alamat;
   - filter suasana memakai `every`, sehingga dua suasana berarti harus
     memenuhi keduanya;
   - filter fasilitas memakai pola yang sama;
   - hasil akhir diurutkan sesuai `PlaceSort`.
4. Demonstrasi langsung:
   - ketik `kopi` → hasil menyempit;
   - hapus kata kunci, pilih "Diskusi kelompok" + "Meja besar";
   - ubah pengurutan menjadi "Biaya terendah";
   - tunjukkan jumlah hasil berubah dan tempat gratis muncul lebih dulu;
   - ketik `zzz` → tampil "Belum ada tempat yang cocok";
   - tekan "Hapus filter" → kembali ke delapan tempat.

## 6. Navigasi dan detail (2 menit)

1. Dari daftar, tekan satu kartu.
2. Di halaman detail, tunjukkan bahwa nama, area, alamat, jam, biaya, dan
   kecocokan aktivitas berasal dari objek yang dipilih.
3. Tekan tombol kembali. Tunjukkan kata kunci dan filter masih terpasang.
4. Jelaskan alasannya: halaman daftar tidak dibuang dari tumpukan navigasi,
   sehingga `State`-nya tetap hidup; detail hanya menerima objek `Place`.

Kalimat kunci: "Navigasi memakai `Navigator.push` dan `pop`. Tidak ada state
global karena lingkupnya cukup lokal."

## 7. Widget dan layout (1 menit)

Buka `lib/widgets/place_card.dart`. Tunjukkan bahwa satu widget punya dua
tampilan: horizontal untuk ponsel, vertikal untuk grid layar lebar. Buka
`lib/pages/places_page.dart` bagian `_ResultsGrid` untuk menunjukkan pemilihan
satu kolom atau dua kolom berdasarkan lebar.

Sebutkan dua teknik responsif yang dipakai: `LayoutBuilder` untuk grid dan
`Wrap` untuk chip agar tidak meluber.

## 8. Perubahan kecil yang bisa dipraktikkan (2 menit)

Contoh yang aman dan cepat, pilih salah satu:

**A. Menambah tempat baru**

1. Tambahkan satu objek pada `assets/data/places.json` dengan `id` baru.
2. Simpan, lalu tekan `r` (hot restart) di terminal.
3. Tunjukkan tempat baru muncul di daftar, dapat difilter, dan detailnya
   terbuka.

**B. Menambah pilihan pengurutan**

1. Tambahkan nilai baru pada `enum PlaceSort` di `lib/data/place_repository.dart`
   (misalnya `priceDesc('Biaya tertinggi')`).
2. Tambahkan satu cabang `case` pada `apply` untuk pengurutan menurun.
3. Simpan dan hot reload. Menu pengurutan otomatis menampilkan pilihan baru
   karena dibangun dari `PlaceSort.values`.

**C. Mengubah ambang layar lebar**

1. Di `lib/pages/places_page.dart`, ubah `wide` dari `>= 720` menjadi `>= 600`.
2. Ubah ukuran jendela browser dan tunjukkan kartu berubah menjadi grid lebih
   awal.

## 9. Penutup (30 detik)

Sebutkan batas yang jujur: data masih fiktif, belum ada backend, dan pengujian
dilakukan lewat `flutter test` serta menjalankan aplikasi, bukan pada perangkat
Android fisik.

## Pertanyaan yang Sering Muncul

**Kenapa tidak memakai Provider atau Bloc?**
Lingkup proyek kecil dan state hanya dipakai dalam satu halaman. `setState`
cukup, dan package tambahan akan menambah lapisan yang tidak memberi manfaat
sepadan.

**Bagaimana kalau data JSON rusak?**
`PlaceRepository.load()` melempar `PlaceDataException`, dan `SelaApp`
menampilkannya sebagai halaman gagal dengan tombol "Coba lagi". Perilaku ini
diuji otomatis di `test/place_repository_test.dart`.

**Bagaimana filter tetap ada setelah kembali dari detail?**
Halaman daftar tetap berada di tumpukan navigasi, sehingga objek `State`
beserta `_query` tidak dibuang. Ini diuji di `test/app_test.dart` pada
pengujian "kembali dari detail mempertahankan kata kunci dan filter".

**Mengapa foto berbeda dengan nama tempat?**
Semua tempat fiktif, dan foto hanya ilustrasi berlisensi. Pemetaan dan
lisensinya ada di `docs/ASSET_SOURCES.md`.

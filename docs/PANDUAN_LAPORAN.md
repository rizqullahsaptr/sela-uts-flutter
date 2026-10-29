# Panduan Laporan UTS — Sela

Dokumen ini menyediakan kerangka laporan enam bagian sesuai ketentuan UTS,
beserta bahan penjelasan dari implementasi yang benar-benar ada, lokasi
cuplikan kode, dan penanda bagian yang masih membutuhkan tambahan dari kamu.

Hal yang **tidak** diisi di sini dan harus kamu lengkapi sendiri: logo fakultas,
nama dosen pengampu, tanggal pengumpulan, hasil pengujian pengguna, dan link
video/PDF setelah benar-benar diunggah.

## Identitas untuk Halaman Judul

| Butir | Isi |
|---|---|
| Judul | Sela: Aplikasi Pencarian Tempat Belajar Berbasis Suasana, Fasilitas, dan Biaya |
| Jenis | Ujian Tengah Semester — Mobile Programming Practicum |
| Nama | Muhammad Rizqullah Saputra |
| NIM | 240605110102 |
| Kelas | E |
| Program studi | Teknik Informatika, Fakultas Sains dan Teknologi, UIN Maulana Malik Ibrahim Malang |
| Dosen pengampu | `[isi nama dosen]` |
| Tanggal | `[isi tanggal pengumpulan]` |
| Logo fakultas | `[sisipkan logo resmi]` |
| Link repository | https://github.com/rizqullahsaptr/Mobile-Programming-Practicum |
| Lokasi source | Folder `UTS/` pada repository — **isi hanya setelah folder benar-benar terunggah dan diperiksa** |
| Link YouTube | `[diisi setelah video diunggah]` |
| Link PDF Google Drive | `[diisi setelah laporan diunggah]` |

## BAB I PENDAHULUAN

Bahan yang bisa dipakai:

- Latar belakang: mahasiswa sering memilih tempat belajar berdasarkan kebiasaan,
  padahal kebutuhan tiap aktivitas berbeda. Tempat untuk mengerjakan tugas
  sendirian tidak selalu sama dengan tempat untuk diskusi kelompok.
- Masalah yang dijawab aplikasi: tempat ini cocok untuk aktivitas apa,
  fasilitasnya apa, dan berapa kisaran biayanya.
- Tujuan: membangun aplikasi Flutter tiga halaman yang menghubungkan pencarian,
  penyaringan, pemilihan, dan detail tempat menggunakan data JSON lokal.
- Batasan: data bersifat fiktif, tanpa login, tanpa backend, tanpa peta atau
  geolokasi, dan tanpa reservasi.
- Manfaat: menjadi dasar pengembangan aplikasi pencarian tempat dengan sumber
  data nyata pada tahap berikutnya.

Sumber: `README.md` bagian "Sela — Panduan Tempat Belajar" dan
"Fitur yang Berjalan".

## BAB II PERANCANGAN ANTARMUKA

Bagian ini membutuhkan **rancangan awal**, bukan screenshot aplikasi.
Gunakan berkas berikut sebagai gambar rancangan:

| Gambar | Berkas | Isi |
|---|---|---|
| Gambar 2.1 | `docs/design/01_beranda.svg` | Wireframe beranda: brand, judul, pencarian, chip kebutuhan, rekomendasi |
| Gambar 2.2 | `docs/design/02_daftar.svg` | Wireframe daftar: pencarian, filter, pengurutan, kartu hasil, keadaan kosong |
| Gambar 2.3 | `docs/design/03_detail.svg` | Wireframe detail: foto, meta informasi, suasana, kecocokan aktivitas |

Cara memasukkan ke laporan: buka SVG di browser atau Inkscape, ekspor PNG
minimal 1200 px lebar, lalu sisipkan. Beri keterangan gambar bahwa ini
**rancangan awal**, bukan tangkapan layar aplikasi.

Bahan narasi:

- Konsep visual: panduan tempat belajar yang tenang dan mudah dipindai.
- Warna: latar krem `#FAF7F0`, teks arang `#23201C`, aksen hijau tua `#1E4B3D`.
- Tipografi: Newsreader untuk judul, Inter untuk teks antarmuka; keduanya
  dibundel sebagai aset.
- Jarak: skala kelipatan 4, dengan 8/16 untuk pemisah bagian.
- Bentuk: sudut kartu 14, border 1 px, tanpa bayangan.
- Alur navigasi: beranda → daftar → detail → kembali ke daftar.

Rujukan lengkap: `docs/UI_DESIGN.md`. Bagian "Perubahan dari Rancangan"
menjelaskan satu perubahan nyata dari wireframe ke implementasi, dan sebaiknya
dikutip agar laporan menunjukkan proses, bukan hanya hasil akhir.

## BAB III IMPLEMENTASI PROGRAM

Cuplikan kode penting beserta lokasinya:

| No | Bahasan | Berkas dan lokasi | Keterangan untuk laporan |
|---|---|---|---|
| 1 | Model data | `lib/models/place.dart` baris 41 (`Place.fromJson`) | Mengubah satu objek JSON menjadi `Place`, dengan penanganan nilai hilang |
| 2 | Format biaya | `lib/models/place.dart` baris 99 (`priceLabel`) | Menampilkan "Gratis", rentang, atau satu nilai |
| 3 | Pembacaan aset | `lib/data/place_repository.dart` baris 41 (`load`) | Satu lapisan data; sumber lokal bisa diganti API |
| 4 | Kriteria pencarian | `lib/data/place_repository.dart` baris 93 (`PlaceQuery`) | Kata kunci, suasana, fasilitas, dan pengurutan dalam satu objek immutable |
| 5 | Penyaringan dan urutan | `lib/data/place_repository.dart` baris 144 (`apply`) | Logika DAN antar-kriteria, lalu pengurutan |
| 6 | Navigasi dari beranda | `lib/pages/home_page.dart` baris 46 (`_submitSearch`) | Membuka daftar dengan kata kunci terpasang |
| 7 | Keadaan filter daftar | `lib/pages/places_page.dart` baris 50 (`_update`) | `setState` menyimpan kriteria agar tidak hilang saat kembali dari detail |
| 8 | Halaman detail | `lib/pages/place_detail_page.dart` baris 10 | Menerima objek `Place`, bukan membaca ulang data |
| 9 | Tema | `lib/theme/app_theme.dart` baris 96 (`buildSelaTheme`) | Warna, tipografi, dan gaya komponen terpusat |
| 10 | Pemuatan data aplikasi | `lib/app.dart` baris 12 (`SelaApp`) | `FutureBuilder` menangani memuat, gagal, dan berhasil |

Yang perlu dijelaskan saat menulis laporan:

1. **Kenapa satu repository.** Semua halaman hanya mengenal `Place`, sehingga
   penggantian JSON menjadi API cukup mengubah `PlaceRepository.load()`.
2. **Kenapa `PlaceQuery` immutable.** Filter mudah dibandingkan dan disalin,
   serta dapat diuji tanpa membangun widget.
3. **Kenapa memakai `Navigator` dan `setState`.** Skala proyek kecil; package
   tambahan belum memberi manfaat yang sepadan.
4. **Bagaimana keadaan daftar dipertahankan.** Halaman daftar tidak dibuang
   saat detail dibuka, sehingga `State` beserta `_query` dan isi kolom
   pencarian tetap hidup ketika pengguna kembali.

## BAB IV HASIL DAN PEMBAHASAN

Screenshot yang tersedia di `docs/screenshots/`, semuanya berasal dari aplikasi
yang benar-benar dijalankan pada build web, bukan mockup:

| Gambar | Berkas | Ukuran | Isi yang ditunjukkan |
|---|---|---|---|
| Gambar 4.1 | `01_beranda.png` | 780×1688 | Beranda: identitas, pencarian, chip kebutuhan, tiga rekomendasi dengan alasan |
| Gambar 4.2 | `02_daftar.png` | 780×1688 | Daftar penuh: 8 tempat, filter terbuka, pengurutan Rekomendasi |
| Gambar 4.3 | `03_daftar_filter.png` | 780×1688 | Filter aktif: "Diskusi kelompok" + "Meja besar", urut Biaya terendah, 5 hasil |
| Gambar 4.4 | `04_detail.png` | 780×3500 | Detail lengkap satu tempat sampai catatan data contoh |
| Gambar 4.5 | `05_hasil_kosong.png` | 780×1688 | Keadaan kosong: "Belum ada tempat yang cocok" dan tombol hapus filter |
| Gambar 4.6 | `06_daftar_lebar.png` | 2048×2000 | Layar lebar: grid dua kolom dengan foto di atas |

Catatan penting saat menulis keterangan gambar:

- Screenshot diambil dari **versi web** aplikasi Flutter pada lebar 390 px
  (ponsel) dan 1024 px (lebar), dengan penskalaan 2×. Jangan menyebutnya
  screenshot perangkat Android.
- Gambar 4.4 memakai tinggi jendela yang diperpanjang agar seluruh halaman
  detail terlihat dalam satu gambar; lebarnya tetap 390 px sehingga tata
  letaknya sama dengan tampilan ponsel.
- Jangan menyebut jam operasional, ketersediaan kursi, atau kondisi ramai
  sebagai informasi langsung. Semua data fiktif dan sudah diberi catatan pada
  antarmuka.

Pembahasan yang bisa diangkat:

1. **Pencarian dan filter.** Kombinasi suasana dan fasilitas memakai logika DAN,
   sehingga hasil menyempit ketika kriteria ditambah. Contoh: "Diskusi
   kelompok" + "Meja besar" menyisakan 5 dari 8 tempat.
2. **Pengurutan.** Biaya terendah memakai `priceMin`, dan tempat gratis
   mendapat nilai 0 sehingga tampil paling awal.
3. **Keadaan kosong.** Kata kunci yang tidak cocok tidak menghasilkan halaman
   kosong tanpa penjelasan; pengguna diberi jalan keluar berupa tombol hapus
   filter.
4. **Konsistensi data antarhalaman.** Detail menerima objek `Place` yang sama
   dengan yang dipilih pada daftar, bukan membaca ulang data berdasarkan indeks.
5. **Responsif.** Di bawah 720 px tampil satu kolom, di atasnya grid dua kolom
   dengan lebar maksimum 860 px.

Hasil pengujian yang boleh diklaim, sesuai yang benar-benar dijalankan:

| Pemeriksaan | Hasil |
|---|---|
| `dart format lib test` | 15 berkas, tidak ada perubahan |
| `flutter analyze` | `No issues found!` |
| `flutter test` | 45 pengujian lulus |
| Pengujian otomatis pencarian, filter, reset, pengurutan | Lulus |
| Pengujian otomatis navigasi dan pemilihan item | Lulus |
| Pengujian otomatis kembali dari detail mempertahankan filter | Lulus |
| Pengujian otomatis tampilan 320×568 dan 1024×768 dengan teks diperbesar | Lulus |
| `flutter build apk --debug` | Berhasil, `app-debug.apk` terbentuk |

Yang **tidak** boleh diklaim: pengujian alur pada perangkat Android fisik,
screenshot Android, pengujian iOS, pengukuran performa, dan pengujian pengguna.
APK debug memang berhasil dibangun, tetapi aplikasi belum diuji menyeluruh di
perangkat, jadi jangan menulis "sudah diuji di Android". Bila kamu melakukan
pengujian pengguna atau pengujian perangkat, tambahkan sendiri subbagiannya
beserta data yang benar-benar kamu kumpulkan.

## BAB V KESIMPULAN

Bahan kesimpulan:

1. Tiga halaman dengan fungsi berbeda sudah terhubung melalui `Navigator`:
   beranda untuk memulai, daftar untuk membandingkan, detail untuk memutuskan.
2. Data JSON lokal dapat dibaca dan diubah menjadi model bertipe, dengan
   penanganan data rusak, aset hilang, dan hasil kosong.
3. Pencarian, kombinasi filter, reset, dan pengurutan bekerja serta dapat
   diuji secara otomatis.
4. Pemisahan lapisan data, model, tema, halaman, dan widget membuat kode lebih
   mudah dijelaskan dan dikembangkan.
5. Batas yang disadari: data masih fiktif dan belum ada integrasi server.

## BAB VI PENUTUP

Isi dengan:

- Kendala nyata yang kamu alami saat mengerjakan (jangan mengarang).
- Rencana pengembangan: mengganti sumber data menjadi API, menyimpan filter
  terakhir, menambah foto tempat yang sebenarnya.
- Ucapan terima kasih dan lampiran: tabel atribusi aset dari
  `docs/ASSET_SOURCES.md`, serta tautan repository, video, dan PDF.

## Daftar Gambar yang Masih Perlu Kamu Siapkan

| Kebutuhan | Status |
|---|---|
| Logo fakultas untuk halaman judul | Belum ada di proyek — tambahkan sendiri |
| Ekspor PNG dari tiga wireframe SVG | Bisa dibuat dari `docs/design/*.svg` |
| Screenshot aplikasi | Sudah tersedia di `docs/screenshots/` |
| Tangkapan layar pengujian di perangkat | Belum ada — hanya jika kamu benar-benar menguji di perangkat |
| Tangkapan layar video/live coding | Belum ada — diisi setelah rekaman dibuat |

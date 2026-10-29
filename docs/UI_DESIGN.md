# UI Design — Sela

Dokumen ini mencatat keputusan visual aplikasi Sela: warna, tipografi, jarak,
bentuk, dan susunan tiap halaman. Rancangan awal ketiga halaman ada di
`docs/design/` sebagai wireframe SVG.

- `docs/design/01_beranda.svg`
- `docs/design/02_daftar.svg`
- `docs/design/03_detail.svg`

Wireframe tersebut adalah **rancangan**, bukan tangkapan layar aplikasi.
Screenshot hasil implementasi berada di `docs/screenshots/`.

## Konsep

Sela dipakai saat mahasiswa sedang memutuskan akan belajar di mana. Keputusan
itu biasanya cepat dan membandingkan beberapa pilihan, sehingga antarmuka
diarahkan pada tiga hal: pemindaian cepat, informasi yang langsung menjawab
pertanyaan, dan ketenangan visual.

Prinsip yang dipakai:

1. Satu pertanyaan per bagian. Beranda bertanya "mau belajar seperti apa?",
   daftar menjawab "mana yang cocok", detail menjawab "apakah tempat ini sesuai".
2. Foto memperkenalkan karakter tempat, teks menjelaskan faktanya. Tidak ada
   angka atau label yang tidak berasal dari data.
3. Warna dipakai hemat. Hijau tua hanya untuk aksi dan penanda pilihan, bukan
   untuk dekorasi.

## Warna

| Peran | Nilai | Pemakaian |
|---|---|---|
| Latar halaman | `#FAF7F0` | Krem sangat muda, bukan putih murni, agar tidak menyilaukan |
| Permukaan kartu | `#FFFFFF` | Kartu, kolom pencarian, panel filter |
| Teks utama | `#23201C` | Arang, kontras ±14:1 pada latar krem |
| Teks sekunder | `#6B645C` | Area, alamat, keterangan; kontras ±5,3:1 |
| Aksen | `#1E4B3D` | Tombol utama, chip terpilih, harga |
| Aksen lembut | `#E7EFE9` | Latar catatan data contoh dan blok suasana |
| Garis | `#E4DED2` | Border kartu dan pemisah |

Tidak ada gradient dekoratif, efek kaca, atau bayangan tebal. Kedalaman
dibentuk oleh border tipis dan perbedaan latar, sehingga tampilan tetap tenang
ketika banyak kartu tampil bersamaan.

Kontras diuji pada pasangan yang benar-benar dipakai: teks utama pada latar
krem, teks sekunder pada permukaan putih, dan teks putih pada tombol hijau.

## Tipografi

Dua keluarga font, keduanya dibundel sebagai aset sehingga tidak ada unduhan
saat aplikasi dibuka:

| Keluarga | Peran | Berkas | Lisensi |
|---|---|---|---|
| Newsreader | Judul halaman dan judul bagian | `assets/fonts/Newsreader.ttf` | SIL OFL 1.1 |
| Inter | Teks isi, label, tombol, angka | `assets/fonts/Inter.ttf` | SIL OFL 1.1 |

Skala yang dipakai:

| Token | Ukuran | Berat | Pemakaian |
|---|---|---|---|
| `title` | 34 | 600 | Judul beranda |
| `sectionTitle` | 23 | 600 | Judul bagian |
| `cardTitle` | 17 | 600 | Nama tempat pada kartu |
| `bodyText` | 15 | 400 | Paragraf isi |
| `bodyMuted` | 14 | 400 | Keterangan sekunder |
| `label` | 13 | 600 | Label chip, tombol, harga |
| `caption` | 12 | 400 | Catatan data contoh |

Tinggi baris 1,5–1,55 untuk teks isi. Judul memakai Newsreader karena
memberi kesan tenang seperti panduan tercetak, sedangkan Inter dipakai untuk
semua teks yang harus dipindai cepat.

## Jarak

Skala kelipatan 4, dengan kelipatan 8 untuk pemisah antar bagian:

| Token | Nilai | Pemakaian |
|---|---|---|
| `xs` | 4 | Jarak ikon dan label |
| `sm` | 8 | Jarak antar chip |
| `md` | 12 | Jarak di dalam kartu |
| `lg` | 16 | Padding kartu dan tepi layar ponsel |
| `xl` | 24 | Pemisah antar bagian |
| `xxl` | 32 | Jarak judul ke isi, padding layar lebar |
| `xxxl` | 48 | Ruang bawah halaman detail |

Tepi halaman 16 pada ponsel dan 32 pada layar lebar. Elemen yang berhubungan
langsung (nama, area, harga) dirapatkan; bagian yang berbeda diberi jarak satu
tingkat lebih besar.

## Bentuk

- Sudut kartu 14, kolom input 12, chip dan tombol pil penuh.
- Border 1 px berwarna `#E4DED2`; tanpa bayangan.
- Ikon bergaya outline dari Material Icons, satu gaya untuk seluruh aplikasi.
  Setiap ikon fasilitas selalu didampingi label teks.
- Gambar selalu 16:9 atau 16:10 dengan `BoxFit.cover`, sehingga kartu tidak
  berubah tinggi ketika foto berbeda rasio.

## Susunan Halaman

### Beranda

Urutan dari atas: identitas Sela, judul "Cari tempat buat fokus.", satu
kalimat pengantar, kolom pencarian, pilihan kebutuhan, tiga rekomendasi, lalu
catatan data contoh.

- Pencarian mengirim kata kunci ke halaman daftar, bukan menyaring beranda.
- Chip kebutuhan langsung membuka daftar dengan filter suasana terpasang.
- Rekomendasi memakai kartu horizontal dengan alasan singkat yang diambil dari
  atribut tempat, misalnya "Area tenang, tersedia stopkontak."
- "Lihat semua" dan tombol "Daftar" menuju daftar tanpa filter.

### Daftar tempat

Urutan: kolom pencarian, baris filter dan hapus filter, panel filter (suasana
dan fasilitas), jumlah hasil beserta pengurutan, lalu kartu hasil.

- Kata kunci yang dibawa dari beranda langsung tampil di kolom pencarian dan
  dapat diubah atau dihapus di sini.
- Panel filter dapat dilipat agar hasil lebih cepat terlihat.
- Filter fasilitas dibatasi empat pilihan: Wi-Fi, stopkontak, ruang tenang,
  meja besar. Pilihan lain tetap tampil di kartu dan detail.
- Pada layar sempit hasil tampil satu kolom kartu horizontal; pada layar lebar
  menjadi grid dua kolom dengan foto di atas.
- Hasil kosong menampilkan penjelasan singkat dan tombol "Hapus filter".
- Pengurutan: Rekomendasi, Nama A–Z, Biaya terendah.

### Detail tempat

Urutan: foto besar, nama, area, alamat contoh, jam operasional, biaya, blok
suasana, deskripsi, kecocokan aktivitas, fasilitas, catatan data contoh.

- Tombol kembali berada di app bar dan memakai `Navigator.pop`, sehingga
  halaman daftar di bawahnya tetap hidup bersama kata kunci dan filternya.
- Kecocokan aktivitas ditampilkan sebagai daftar berikon: untuk aktivitas apa
  tempat ini cocok dan alasannya.
- Tidak ada tombol reservasi, peta, atau tombol lain yang belum berfungsi.

## Responsif

- Ambang 720 px: di bawahnya memakai satu kolom dan tepi 16 px, di atasnya
  memakai lebar maksimum 760–860 px dan tepi 32 px.
- Kartu daftar berubah dari horizontal menjadi grid dua kolom pada layar lebar.
- Semua teks memakai skala dari `ThemeData`, sehingga pembesaran ukuran teks
  sistem tidak memotong label; elemen yang berisiko meluber memakai `Wrap`,
  `Flexible`, atau `maxLines` dengan elipsis.
- Gambar memakai `AspectRatio` agar tinggi kartu tetap stabil di berbagai
  lebar layar.

## Perubahan dari Rancangan

Rancangan awal memakai kartu rekomendasi vertikal dengan foto besar. Setelah
implementasi, kartu rekomendasi di beranda diubah menjadi horizontal agar tiga
tempat terlihat dalam satu layar tanpa banyak menggulir, sementara foto besar
dipindah ke halaman detail. Alasan perubahan: tujuan beranda adalah
membandingkan beberapa pilihan, bukan menampilkan satu tempat secara mendalam.

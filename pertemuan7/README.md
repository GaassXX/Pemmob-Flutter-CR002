# Pertemuan 7: Mini Proyek Terpadu — TabungKu

Aplikasi Flutter terpadu yang memadukan To-Do List dan Manajemen Keuangan Harian (TabungKu). Mengintegrasikan materi Pertemuan 1–6: Widget, Layout, Form & Validasi, SQLite, SharedPreferences, Tema, Navigasi Tab, Named Routes, dan Animasi Progress.

---

## 1. Struktur Folder & Kode (Format Pertemuan 6)

```text
lib/
├── DocTugas/
│   └── penjelasan.md          # Laporan penjelasan, 10 skenario uji, & jawaban 5 pertanyaan refleksi
├── modul/
│   └── modul-praktikum-flutter-pertemuan-7.pdf
├── praktikum/
│   ├── BagianA.dart           # Model Kegiatan & Ringkasan, Utilitas Format, SQLite DbHelper
│   ├── BagianB.dart           # Halaman Hari Ini, Daftar Kegiatan, Checkbox Selesai & Dialog Hapus
│   ├── BagianC.dart           # Form Tambah & Ubah Kegiatan dengan Validasi & DatePicker
│   └── BagianD.dart           # Halaman Laporan, Pengaturan (SharedPreferences), & Navigasi 3 Tab
├── tugas/
│   └── Tugas.dart             # Aplikasi Lengkap TabungKu (Standalone & Terpadu)
├── Latihan_mandiri.dart       # Pengembangan Lanjutan: Pencarian & Filter Kegiatan, Ekspor Clipboard
└── main.dart                  # Entry point aplikasi utama
```

---

## 2. Fitur Utama (F1–F8)

1. **F1 (Daftar Kegiatan Hari Ini)**: Menampilkan kegiatan hari ini, status selesai (checkbox dengan coret judul), ubah data, dan hapus dengan dialog konfirmasi.
2. **F2 (Form Validasi)**: Validasi nama kegiatan (tidak boleh kosong), pemilih tanggal (DatePicker), pilihan transaksi (*Tidak*, *Pemasukan*, *Pengeluaran*), validasi nominal wajib > 0 bila ada uang, dan pemilihan kategori pengeluaran.
3. **F3 (Penyimpanan SQLite)**: Data tersimpan persisten di tabel SQLite `kegiatan` (`tabungku_praktikum.db`).
4. **F4 (Ringkasan Finansial)**: Ringkasan dinamis jumlah kegiatan, status selesai, total pemasukan, total pengeluaran, dan tabungan bersih harian.
5. **F5 (Laporan Keuangan & Analitik)**: Pemilih tanggal, ringkasan per tanggal terpilih, agregasi pengeluaran per kategori, dan riwayat ringkasan 7 hari terakhir.
6. **F6 (Target Tabungan Beranimasi)**: Slider target harian dengan progress bar beranimasi (`LinearProgressIndicator` + `TweenAnimationBuilder`), deteksi tabungan negatif, dan apresiasi target tercapai.
7. **F7 (Pengaturan Tersimpan)**: Pengaturan mode gelap/terang, pilihan warna seed tema Material 3, dan nominal target tersimpan di `SharedPreferences`.
8. **F8 (Navigasi Tab & Named Routes)**: Tab bar modern via `NavigationBar` (Hari Ini, Laporan, Pengaturan) dan navigasi bernama (`/tambah`).

---

## 3. Fitur Pengembangan Lanjutan (`Latihan_mandiri.dart`)

- **Pencarian dan Filter Dinamis**: Pencarian kegiatan berdasarkan nama (query `LIKE`) serta filter berdasarkan jenis transaksi (Semua / Pemasukan / Pengeluaran) dan kategori pengeluaran.
- **Ekspor Laporan Harian**: Fitur menyalin ringkasan laporan dan rincian transaksi hari ini ke Clipboard sistem untuk kemudahan berbagi laporan.

---

## 4. Cara Menjalankan

```bash
# Mengambil dependensi
flutter pub get

# Menjalankan aplikasi utama
flutter run lib/main.dart

# Menjalankan checkpoint praktikum tertentu
flutter run lib/praktikum/BagianA.dart
flutter run lib/praktikum/BagianB.dart
flutter run lib/praktikum/BagianC.dart
flutter run lib/praktikum/BagianD.dart

# Menjalankan latihan mandiri
flutter run lib/Latihan_mandiri.dart
```

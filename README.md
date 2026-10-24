# 📱 Pemrograman Mobile (Flutter) - CR002

Repositori ini berisi kumpulan materi, modul praktikum, tugas mandiri, serta perancangan proyek akhir (Project Draft BRD & PRD) untuk mata kuliah **Pemrograman Mobile** menggunakan framework **Flutter & Dart**.

---

## 👨‍💻 Profil Mahasiswa
- **Nama**: Rizqi Bagas Wicaksono
- **Kelas**: CR002
- **Mata Kuliah**: Pemrograman Mobile
- **Framework**: Flutter & Dart

---

## 📂 Struktur Repositori

```	ext
├── Draft_BRD _ PRD -Project/  # Dokumen perancangan proyek akhir (BRD & PRD DompetKuu)
│   ├── BRD_DompetKuu_darft.pdf
│   └── PRD_DompetKuu_draft.pdf
├── pertemuan1/                # Pertemuan 1: Pengenalan Flutter & Basic Widget
├── pertemuan2/                # Pertemuan 2: Layouting & UI Components
├── pertemuan3/                # Pertemuan 3: User Input, Form & State Management Dasar
├── pertemuan4/                # Pertemuan 4: Navigasi, Routing, Models & Service
├── pertemuan5/                # Pertemuan 5: Penyimpanan Lokal (SQLite & Shared Preferences)
├── pertemuan6/                # Pertemuan 6: Penerapan Tema, Preferensi & State Lanjutan
├── pertemuan7/ - pertemuan9/  # Folder project praktikum lanjutan
```

---

## 📚 Ringkasan Pertemuan Praktikum

| Pertemuan | Topik Utama | Komponen / Fitur Utama | Tugas / Latihan |
| :---: | :--- | :--- | :--- |
| **01** | Pengenalan Flutter & Basic Widget | Text, Container, Row, Column, Scaffold | Kartu Pengenal Sederhana & Latihan Mandiri |
| **02** | Layouting & Profiling UI | Card, ListTile, ListView, Divider, Styling | Aplikasi Daftar Kontak & Profil |
| **03** | Formulir, Input & Interaksi | TextField, Dropdown, Checkbox, Form Validation | Aplikasi Daftar Belanja Interaktif |
| **04** | Navigasi, Models & Service | Navigator, Routing, Models, Business Logic Separation | Aplikasi Salam & Manajemen Data Mandiri |
| **05** | Penyimpanan Data Lokal | SQLite (`sqflite`), `shared_preferences`, Format Rupiah | Aplikasi Pencatatan Transaksi Finansial |
| **06** | Tema Dinamis & Preferensi Sistem | Dark Mode / Light Mode, Seed Color Palette, Persistent Theme | Sistem Tema & Pengaturan Aplikasi Dinamis |

Setiap folder pertemuan dilengkapi dengan:
- 📖 **Modul Praktikum (PDF)** di dalam subfolder `lib/modul/`
- 🧪 **Latihan Praktikum** di dalam `lib/Praktikum/`
- 📝 **Tugas Mandiri** di dalam `lib/Tugas/` dan `lib/Latihan_mandiri.dart`
- 📑 **Dokumentasi Tugas** di dalam `lib/DocTugas/`

---

## 🚀 Panduan Menjalankan Project

### Prasyarat
- Flutter SDK (versi terbaru stabil)
- Dart SDK
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android atau Device Fisik dengan mode USB Debugging aktif

### Langkah Menjalankan:

1. **Clone repositori:**
```bash
git clone https://github.com/GaassXX/Pemmob-Flutter-CR002.git
cd Pemmob-Flutter-CR002
```

2. **Pilih folder pertemuan yang ingin dijalankan (contoh: Pertemuan 5):**
```bash
cd pertemuan5
```

3. **Install dependensi package:**
```bash
flutter pub get
```

4. **Jalankan aplikasi:**
```bash
flutter run
```

---

## 📌 Proyek Akhir
Folder `Draft_BRD _ PRD -Project/` berisi dokumen spesifikasi kebutuhan sistem (**DompetKuu**):
- **BRD (Business Requirement Document)**: Kebutuhan bisnis, target pengguna, dan arsitektur fitur.
- **PRD (Product Requirement Document)**: Detail implementasi teknis, user flow, dan ruang lingkup pengembangan.

---
*Dikembangkan oleh [GaassXX](https://github.com/GaassXX) untuk kegiatan praktikum Pemrograman Mobile.*

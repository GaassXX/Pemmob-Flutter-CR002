# Doc Tugas - Pertemuan 7: Mini Proyek Terpadu TabungKu

Disusun oleh: Rizqi Bagas Wicaksono  
NIM: 20240801187

---

## 1. Tujuan Pembelajaran & Deskripsi Mini Proyek
Mini proyek **TabungKu** memadukan seluruh materi fundamental dari Pertemuan 1 hingga 6 ke dalam satu aplikasi produktivitas dan finansial harian:
1. **Penyimpanan Lokal Relasional (SQLite)** untuk kegiatan to-do list dan transaksi keuangan.
2. **Pengaturan Preferensi (SharedPreferences)** untuk menyimpan target tabungan, tema gelap/terang, dan variasi warna aksen secara persisten.
3. **Form & Validasi Input**: Input nama kegiatan, penanggalan via DatePicker, pilihan jenis transaksi dinamis, serta nominal dan kategori.
4. **Navigasi Tab Modern**: Menggunakan `NavigationBar` 3 tab (Hari Ini, Laporan, Pengaturan) dan navigasi bernama (`named routes`).
5. **State Synchronization via Observer Pattern**: Menggunakan `ValueNotifier<int> versiData` agar ketiga tab selalu tersinkronisasi seketika saat data bertambah, berubah, atau terhapus.

---

## 2. Struktur Proyek
- `lib/praktikum/BagianA.dart`: Model `Kegiatan`, enum `Tipe`, kelas `Ringkasan`, `FormatHelper`, dan `DbHelper`.
- `lib/praktikum/BagianB.dart`: Tampilan Beranda Hari Ini, daftar item kegiatan dengan checkbox selesai, dan dialog konfirmasi hapus.
- `lib/praktikum/BagianC.dart`: Form Tambah dan Ubah kegiatan dengan validasi lengkap.
- `lib/praktikum/BagianD.dart`: Halaman Laporan, Pengaturan (SharedPreferences), dan wadah navigasi 3 tab.
- `lib/tugas/Tugas.dart`: Implementasi aplikasi **TabungKu** mandiri dan terintegrasi penuh.
- `lib/Latihan_mandiri.dart`: Fitur pengembangan lanjutan (Pencarian/Filter multi-parameter dan Ekspor Laporan ke Clipboard).
- `lib/main.dart`: Entry point utama aplikasi TabungKu.

---

## 3. Hasil Pengujian Skenario (Skenario Uji Modul)

| No | Skenario Pengujian | Hasil yang Diharapkan | Status | Catatan |
|---|---|---|---|---|
| 1 | Tambah kegiatan "Belajar" jenis Tidak | Muncul di daftar; jumlah bertambah; pemasukan & pengeluaran tetap | Lulus | Nominal bernilai 0 dan kategori '-' |
| 2 | Tambah kegiatan Pemasukan Rp 50.000 | Pemasukan Rp 50.000; tabungan naik Rp 50.000; nominal hijau dengan tanda + | Lulus | Query SUM langsung mengagregasikan nilai pemasukan |
| 3 | Tambah kegiatan Pengeluaran Rp 15.000 kategori Makan | Pengeluaran naik Rp 15.000; tabungan berkurang; kategori Makan muncul di laporan | Lulus | Tampil di grafik/ringkasan kategori |
| 4 | Simpan kegiatan nama kosong / nominal 0 | Pesan kesalahan tampil dan data tidak disimpan | Lulus | Validator form memblokir eksekusi |
| 5 | Centang selesai kegiatan | Kartu ringkasan memperbarui jumlah selesai; judul tercoret (*strikethrough*) | Lulus | Update kolom selesai (1/0) |
| 6 | Ubah nominal kegiatan yang ada | Ringkasan dan laporan langsung ikut berubah tanpa restart | Lulus | `versiData.value++` memicu pemuatan ulang Future |
| 7 | Hapus kegiatan (Batal lalu Hapus) | Batal tidak menghapus; Hapus menghapus data & ringkasan berkurang | Lulus | Dialog konfirmasi berfungsi presisi |
| 8 | Tambah kegiatan bertanggal kemarin | Tidak muncul di Hari Ini; muncul di Laporan tanggal terkait & 7 hari | Lulus | Filter `tanggal = ?` bekerja akurat |
| 9 | Ubah target & tema gelap, restart app | Semua pengaturan dan data kegiatan tetap tersimpan | Lulus | `SharedPreferences` memuat state awal dengan benar |
| 10 | Pengeluaran > Pemasukan | Tabungan negatif berwarna merah dan muncul pesan peringatan | Lulus | Visual feedback peringatan tabungan tekor tampil |

---

## 4. Jawaban Pertanyaan Refleksi Modul

### 1. Mengapa tanggal disimpan sebagai teks `yyyy-MM-dd` dan bukan format lain seperti `dd/MM/yyyy`?
**Jawaban:**
Format `yyyy-MM-dd` mengikuti standar ISO 8601 yang memiliki sifat *lexicographical ordering*. Karena tahun berada di depan diikuti bulan dan tanggal dengan padding dua digit, pengurutan alfabetis/string di SQLite (`ORDER BY tanggal ASC/DESC`) maupun operasi perbandingan (`tanggal >= '2026-10-01'`) akan menghasilkan urutan kronologis yang selalu tepat. Format `dd/MM/yyyy` akan salah saat diurutkan sebagai teks (misalnya tanggal 02/01/2026 akan dianggap lebih awal daripada 03/12/2025).

### 2. Mengapa laporan dihitung dengan query SUM di database, bukan dengan menjumlahkan di Dart? Kapan cara sebaliknya lebih tepat?
**Jawaban:**
Query agregasi di database (`SUM`, `COUNT`, `GROUP BY`) dioptimasi langsung di level SQLite mesin C native. Ini menghemat penggunaan memori RAM (HP tidak perlu memuat ribuan baris objek Dart ke memori hanya untuk menjumlahkan angka) dan jauh lebih cepat.  
Cara sebaliknya (menjumlahkan di Dart) lebih tepat jika jumlah baris data sangat sedikit (< 20 baris) dan sudah berada di memori aplikasi untuk kebutuhan lain, atau jika logika kalkulasinya melibatkan aturan komputasi bisnis yang sangat dinamis yang sulit atau tidak efisien jika dituliskan dalam query SQL.

### 3. Bagaimana tiga tab dapat menampilkan data yang selalu sinkron? Apa risikonya bila `removeListener` lupa dipanggil?
**Jawaban:**
Sinkronisasi dicapai dengan **Observer Pattern** menggunakan variabel global `ValueNotifier<int> versiData`. Setiap kali operasi database (tambah, ubah, hapus) selesai, nilai `versiData.value++` dinaikkan. Masing-masing tab yang menampilkan data mendaftarkan pendengar (`versiData.addListener`) di `initState` untuk memanggil `setState` memuat Future baru.  
Risiko jika `removeListener` lupa dipanggil di method `dispose()` adalah terjadinya **Memory Leak** (kebocoran memori), karena instance State widget yang sudah tidak aktif tetap dipegang referensinya oleh Notifier global. Selain itu, pemanggilan listener pada widget yang sudah dilepas (*disposed*) dapat memicu crash/eksepsi *"setState() called after dispose()"*.

### 4. Apa dampak keputusan "semua kegiatan dihitung, bukan hanya yang selesai" terhadap kebiasaan menabung pengguna?
**Jawaban:**
Keputusan ini menerapkan prinsip **anggaran/budgeting berbasis rencana**. Begitu pengguna mencatat kegiatan pengeluaran atau pemasukan, dampaknya langsung tercermin pada saldo tabungan harian. Hal ini mencegah pengguna *over-spending* (terlanjur menghabiskan uang) sebelum kegiatannya benar-benar selesai dilakukan, sehingga melatih disiplin menabung sejak tahap perencanaan kegiatan harian.

### 5. Bagian mana dari aplikasi ini yang paling sulit, dan apa yang akan Anda ubah bila mengerjakannya ulang?
**Jawaban:**
Bagian yang paling membutuhkan ketelitian adalah query agregasi gabungan (`CASE WHEN` & `COALESCE`) di SQLite untuk memastikan nilai NULL tidak menyebabkan error tipe `Null is not subtype of int` saat belum ada data sama sekali. Jika mengerjakannya ulang, saya akan memisahkan layer database menggunakan repository pattern atau menggunakan state management terstruktur seperti Provider/Riverpod/Bloc untuk skala aplikasi yang lebih besar, serta menambahkan dukungan ekspor laporan ke format PDF.

import 'package:flutter/material.dart';

void main() {
  runApp(const TabungKuApp());
}

// Widget root aplikasi
class TabungKuApp extends StatelessWidget {
  const TabungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabungKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Palet warna tema Modern Navy / Blue Fintech
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const RingkasanPage(),
    );
  }
}

// Halaman Ringkasan Tabungan
class RingkasanPage extends StatelessWidget {
  const RingkasanPage({super.key});

  // Data transaksi statis (hard-coded) seputar perkuliahan dan tabungan
  static const List<Map<String, dynamic>> transaksi = [
    {
      'judul': 'Menabung Rutin Bulanan',
      'tanggal': '01 Nov 2026',
      'nominal': '+ Rp 500.000',
      'isMasuk': true,
    },
    {
      'judul': 'Tarik – Bayar UKT Kuliah',
      'tanggal': '05 Nov 2026',
      'nominal': '- Rp 1.500.000',
      'isMasuk': false,
    },
    {
      'judul': 'Menabung Beasiswa Kuliah',
      'tanggal': '10 Nov 2026',
      'nominal': '+ Rp 750.000',
      'isMasuk': true,
    },
    {
      'judul': 'Tarik – Beli Buku Kuliah',
      'tanggal': '12 Nov 2026',
      'nominal': '- Rp 200.000',
      'isMasuk': false,
    },
    {
      'judul': 'Menabung Uang Saku',
      'tanggal': '14 Nov 2026',
      'nominal': '+ Rp 300.000',
      'isMasuk': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar bernuansa Deep Navy Blue dengan judul di tengah
      appBar: AppBar(
        title: const Text(
          'Ringkasan Tabungan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      // SingleChildScrollView mencegah error overflow di layar ponsel maupun tablet
      body: SingleChildScrollView(
        // Center + ConstrainedBox menjaga lebar layout proporsional di layar lebar / tablet
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu informasi tabungan utama
                  _kartuTabungan(),
                  const SizedBox(height: 20),
                  // Tiga tombol/ikon ringkas penanda kategori
                  _barisKategori(),
                  const SizedBox(height: 24),
                  // Judul seksi daftar riwayat transaksi
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar riwayat transaksi masuk (hijau) & keluar (merah)
                  _daftarTransaksi(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Kartu (Card) utama berisi nama tabungan, saldo, dan target disusun dengan Column dan Row
  Widget _kartuTabungan() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF1E3A8A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris header kartu: Ikon celengan + nama tabungan & deskripsi
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                // Expanded mencegah overflow jika judul tabungan panjang / layar sempit
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tabungan Kuliah',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Rekening Utama',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Baris berisi Saldo Saat Ini dan Target dengan pemisah garis vertikal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Saat Ini',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rp 3.000.000',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Garis vertikal pemisah kolom
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Rp 12.000.000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Baris label persentase pencapaian target
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pencapaian Target',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                Text(
                  '25,0%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Indikator progres target tabungan (25% tercapai) bernuansa aksen cyan/putih
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.25,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                minHeight: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Satu baris (Row) berisi tiga tombol/ikon ringkas penanda kategori (Menabung, Tarik, Riwayat)
  Widget _barisKategori() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _KategoriItem(
          ikon: Icons.add_circle_outline,
          label: 'Menabung',
          warnaLatar: Color(0xFFE0F2FE), // Soft Cyan/Blue
          warnaIkon: Color(0xFF0284C7),
        ),
        _KategoriItem(
          ikon: Icons.remove_circle_outline,
          label: 'Tarik',
          warnaLatar: Color(0xFFFFE4E6), // Soft Rose
          warnaIkon: Color(0xFFE11D48),
        ),
        _KategoriItem(
          ikon: Icons.history,
          label: 'Riwayat',
          warnaLatar: Color(0xFFF1F5F9), // Soft Slate
          warnaIkon: Color(0xFF475569),
        ),
      ],
    );
  }

  // Daftar sederhana transaksi dengan ikon simbol masuk (hijau) dan keluar (merah)
  Widget _daftarTransaksi() {
    return Column(
      children: transaksi.map((t) {
        final bool isMasuk = t['isMasuk'] as bool;
        // Aksen warna standar finansial: hijau untuk pemasukan, merah untuk pengeluaran
        final Color warnaAksen =
            isMasuk ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
        final Color warnaLatarIkon =
            isMasuk ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6);
        final IconData simbolArah =
            isMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Kotak simbol panah transaksi (hijau masuk, merah keluar)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: warnaLatarIkon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(simbolArah, color: warnaAksen, size: 22),
              ),
              const SizedBox(width: 12),
              // Judul dan tanggal transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['judul'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t['tanggal'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Nominal transaksi (+ hijau atau - merah)
              Text(
                t['nominal'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: warnaAksen,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Widget untuk masing-masing tombol penanda kategori
class _KategoriItem extends StatelessWidget {
  final IconData ikon;
  final String label;
  final Color warnaLatar;
  final Color warnaIkon;

  const _KategoriItem({
    required this.ikon,
    required this.label,
    required this.warnaLatar,
    required this.warnaIkon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: warnaLatar,
            shape: BoxShape.circle,
          ),
          child: Icon(ikon, color: warnaIkon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: warnaIkon,
          ),
        ),
      ],
    );
  }
}

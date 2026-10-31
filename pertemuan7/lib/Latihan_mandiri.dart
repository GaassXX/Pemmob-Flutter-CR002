import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'praktikum/BagianA.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: LatihanMandiriPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class LatihanMandiriPage extends StatefulWidget {
  const LatihanMandiriPage({super.key});

  @override
  State<LatihanMandiriPage> createState() => _LatihanMandiriPageState();
}

class _LatihanMandiriPageState extends State<LatihanMandiriPage> {
  String _keyword = '';
  Tipe? _filterTipe;
  String _filterKategori = 'Semua';
  late Future<List<Kegiatan>> _futureHasil;

  final List<String> _kategoriList = [
    'Semua',
    'Makan',
    'Transport',
    'Belajar',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _cari();
    versiData.addListener(_cari);
  }

  @override
  void dispose() {
    versiData.removeListener(_cari);
    super.dispose();
  }

  void _cari() {
    setState(() {
      _futureHasil = _queryFilter();
    });
  }

  Future<List<Kegiatan>> _queryFilter() async {
    final db = await DbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (_keyword.trim().isNotEmpty) {
      whereClause += ' AND judul LIKE ?';
      whereArgs.add('%${_keyword.trim()}%');
    }

    if (_filterTipe != null) {
      whereClause += ' AND tipe = ?';
      whereArgs.add(_filterTipe!.name);
    }

    if (_filterKategori != 'Semua') {
      whereClause += ' AND kategori = ?';
      whereArgs.add(_filterKategori);
    }

    final res = await db.query(
      'kegiatan',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'tanggal DESC, id DESC',
    );
    return res.map((m) => Kegiatan.fromMap(m)).toList();
  }

  Future<void> _eksporLaporanClipboard() async {
    final tgl = FormatHelper.tanggalSekarang();
    final ringkas = await DbHelper.ringkasan(tgl);
    final list = await DbHelper.pada(tgl);

    final sb = StringBuffer();
    sb.writeln('=== LAPORAN HARIAN TABUNGKU ===');
    sb.writeln('Tanggal: ${FormatHelper.tanggalIndo(tgl)}');
    sb.writeln('Total Kegiatan: ${ringkas.jumlahKegiatan} (Selesai: ${ringkas.selesai})');
    sb.writeln('Total Pemasukan: ${FormatHelper.rupiah(ringkas.pemasukan)}');
    sb.writeln('Total Pengeluaran: ${FormatHelper.rupiah(ringkas.pengeluaran)}');
    sb.writeln('Tabungan Hari Ini: ${FormatHelper.rupiah(ringkas.tabungan)}');
    sb.writeln('--------------------------------');
    sb.writeln('Rincian Kegiatan:');
    for (int i = 0; i < list.length; i++) {
      final k = list[i];
      final status = k.selesai ? '[V]' : '[ ]';
      final ket = k.tipe == Tipe.tanpa
          ? 'Tanpa uang'
          : '${k.tipe.name}: ${FormatHelper.rupiah(k.nominal)} (${k.kategori})';
      sb.writeln('${i + 1}. $status ${k.judul} - $ket');
    }
    sb.writeln('================================');

    await Clipboard.setData(ClipboardData(text: sb.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan hari ini berhasil disalin ke Clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Mandiri — Pencarian & Ekspor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Ekspor Laporan Hari Ini',
            onPressed: _eksporLaporanClipboard,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama kegiatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) {
                _keyword = val;
                _cari();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua Jenis'),
                  selected: _filterTipe == null,
                  onSelected: (_) {
                    setState(() => _filterTipe = null);
                    _cari();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pemasukan'),
                  selected: _filterTipe == Tipe.pemasukan,
                  onSelected: (_) {
                    setState(() => _filterTipe = Tipe.pemasukan);
                    _cari();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pengeluaran'),
                  selected: _filterTipe == Tipe.pengeluaran,
                  onSelected: (_) {
                    setState(() => _filterTipe = Tipe.pengeluaran);
                    _cari();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterKategori,
                  items: _kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _filterKategori = val);
                      _cari();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Kegiatan>>(
              future: _futureHasil,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Tidak ada kegiatan yang sesuai filter.'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final k = list[i];
                    return ListTile(
                      leading: Icon(
                        k.tipe == Tipe.pemasukan
                            ? Icons.arrow_downward
                            : (k.tipe == Tipe.pengeluaran ? Icons.arrow_upward : Icons.event),
                        color: k.tipe == Tipe.pemasukan
                            ? Colors.green
                            : (k.tipe == Tipe.pengeluaran ? Colors.red : Colors.grey),
                      ),
                      title: Text(k.judul),
                      subtitle: Text('${k.tanggal} • ${k.kategori}'),
                      trailing: Text(
                        k.tipe == Tipe.tanpa ? '-' : FormatHelper.rupiah(k.nominal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: k.tipe == Tipe.pemasukan ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

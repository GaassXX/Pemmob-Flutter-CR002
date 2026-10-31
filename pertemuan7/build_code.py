import os

files = {}

# ==========================================
# 1. BagianA.dart
# ==========================================
files['lib/praktikum/BagianA.dart'] = '''import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

enum Tipe { tanpa, pemasukan, pengeluaran }

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal;
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final String kategori;

  Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    required this.tipe,
    this.nominal = 0,
    this.kategori = '-',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'judul': judul,
        'tanggal': tanggal,
        'selesai': selesai ? 1 : 0,
        'tipe': tipe.name,
        'nominal': nominal,
        'kategori': kategori,
      };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        tanggal: m['tanggal'] as String,
        selesai: (m['selesai'] as int) == 1,
        tipe: Tipe.values.byName(m['tipe'] as String),
        nominal: m['nominal'] as int,
        kategori: (m['kategori'] as String?) ?? '-',
      );

  Kegiatan copyWith({
    int? id,
    String? judul,
    String? tanggal,
    bool? selesai,
    Tipe? tipe,
    int? nominal,
    String? kategori,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      tanggal: tanggal ?? this.tanggal,
      selesai: selesai ?? this.selesai,
      tipe: tipe ?? this.tipe,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
    );
  }
}

class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;

  const Ringkasan({
    required this.jumlahKegiatan,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
  });

  int get tabungan => pemasukan - pengeluaran;

  static const kosong = Ringkasan(
    jumlahKegiatan: 0,
    selesai: 0,
    pemasukan: 0,
    pengeluaran: 0,
  );
}

class FormatHelper {
  static String rupiah(int nominal) {
    String str = nominal.abs().toString();
    String hasil = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      hasil = str[i] + hasil;
      if (count % 3 == 0 && i != 0) {
        hasil = '.';
      }
    }
    final tanda = nominal < 0 ? '-Rp ' : 'Rp ';
    return '';
  }

  static String tanggalIndo(String yyyyMmDd) {
    try {
      final parts = yyyyMmDd.split('-');
      if (parts.length != 3) return yyyyMmDd;
      const bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final bIndex = int.parse(parts[1]);
      final hari = int.parse(parts[2]);
      final tahun = parts[0];
      return '  ';
    } catch (_) {
      return yyyyMmDd;
    }
  }

  static String tanggalSekarang() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '--';
  }
}

final ValueNotifier<int> versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'tabungku_praktikum.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(\'\'\'
          CREATE TABLE kegiatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL,
            tipe TEXT NOT NULL,
            nominal INTEGER NOT NULL,
            kategori TEXT NOT NULL
          )
        \'\'\');
      },
    );
  }

  static Future<int> tambah(Kegiatan k) async {
    final db = await database;
    final id = await db.insert('kegiatan', k.toMap());
    versiData.value++;
    return id;
  }

  static Future<int> ubah(Kegiatan k) async {
    final db = await database;
    final hasil = await db.update(
      'kegiatan',
      k.toMap(),
      where: 'id = ?',
      whereArgs: [k.id],
    );
    versiData.value++;
    return hasil;
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    final hasil = await db.delete(
      'kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );
    versiData.value++;
    return hasil;
  }

  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await database;
    final hasil = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'selesai ASC, id DESC',
    );
    return hasil.map((m) => Kegiatan.fromMap(m)).toList();
  }

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await database;
    final hasil = await db.rawQuery(\'\'\'
      SELECT COUNT(*) AS jumlah,
             COALESCE(SUM(selesai), 0) AS selesai,
             COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
             COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
    \'\'\', [tanggal]);

    if (hasil.isEmpty) return Ringkasan.kosong;
    final baris = hasil.first;
    return Ringkasan(
      jumlahKegiatan: (baris['jumlah'] as int?) ?? 0,
      selesai: (baris['selesai'] as int?) ?? 0,
      pemasukan: (baris['masuk'] as int?) ?? 0,
      pengeluaran: (baris['keluar'] as int?) ?? 0,
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: BagianAPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class BagianAPage extends StatefulWidget {
  const BagianAPage({super.key});

  @override
  State<BagianAPage> createState() => _BagianAPageState();
}

class _BagianAPageState extends State<BagianAPage> {
  String status = 'Tekan tombol untuk tes simpan data uji ke SQLite';
  List<Kegiatan> listKegiatan = [];

  Future<void> _ujiDatabase() async {
    final hariIni = FormatHelper.tanggalSekarang();
    await DbHelper.tambah(Kegiatan(
      judul: 'Uji Coba SQLite Bagian A',
      tanggal: hariIni,
      tipe: Tipe.pemasukan,
      nominal: 25000,
    ));

    final data = await DbHelper.pada(hariIni);
    final ringkas = await DbHelper.ringkasan(hariIni);

    setState(() {
      listKegiatan = data;
      status = 'Sukses! Total data hari ini: , '
          'Pemasukan: ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 7 - Bagian A (Model & Database)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _ujiDatabase,
              icon: const Icon(Icons.storage),
              label: const Text('Jalankan Tes Simpan & Baca SQLite'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  status,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: listKegiatan.length,
                itemBuilder: (ctx, i) {
                  final item = listKegiatan[i];
                  return ListTile(
                    title: Text(item.judul),
                    subtitle: Text(' • '),
                    trailing: Text(FormatHelper.rupiah(item.nominal)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'''

# ==========================================
# 2. BagianB.dart (Hari Ini & KegiatanTile)
# ==========================================
files['lib/praktikum/BagianB.dart'] = '''import 'package:flutter/material.dart';
import 'BagianA.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: BagianBPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class BagianBPage extends StatefulWidget {
  const BagianBPage({super.key});

  @override
  State<BagianBPage> createState() => _BagianBPageState();
}

class _BagianBPageState extends State<BagianBPage> {
  final String _tanggalHariIni = FormatHelper.tanggalSekarang();
  late Future<List<Kegiatan>> _futureList;

  @override
  void initState() {
    super.initState();
    _futureList = DbHelper.pada(_tanggalHariIni);
    versiData.addListener(_muatUlang);
  }

  @override
  void dispose() {
    versiData.removeListener(_muatUlang);
    super.dispose();
  }

  void _muatUlang() {
    setState(() {
      _futureList = DbHelper.pada(_tanggalHariIni);
    });
  }

  Future<void> _tambahContoh() async {
    await DbHelper.tambah(Kegiatan(
      judul: 'Contoh Kegiatan \',
      tanggal: _tanggalHariIni,
      tipe: Tipe.pengeluaran,
      nominal: 15000,
      kategori: 'Makan',
    ));
  }

  Future<void> _konfirmasiHapus(Kegiatan item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kegiatan 

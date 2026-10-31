import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BagianA.dart';
import 'BagianC.dart';

// Notifiers untuk Pengaturan Tema & Target
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Color> seedColorNotifier = ValueNotifier(Colors.indigo);
final ValueNotifier<int> targetTabunganNotifier = ValueNotifier(20000);

final Map<String, Color> daftarPilihanWarna = {
  'Indigo': Colors.indigo,
  'Teal': Colors.teal,
  'Oranye': Colors.deepOrange,
  'Pink': Colors.pink,
  'Hijau': Colors.green,
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final modeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
  themeModeNotifier.value = ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)];

  final colorVal = prefs.getInt('seedColor');
  if (colorVal != null) seedColorNotifier.value = Color(colorVal);

  final targetVal = prefs.getInt('targetTabungan') ?? 20000;
  targetTabunganNotifier.value = targetVal;

  runApp(const MyAppBagianD());
}

class MyAppBagianD extends StatelessWidget {
  const MyAppBagianD({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeModeNotifier, seedColorNotifier]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 7 - Bagian D',
          debugShowCheckedModeBanner: false,
          themeMode: themeModeNotifier.value,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColorNotifier.value,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColorNotifier.value,
            brightness: Brightness.dark,
          ),
          home: const ShellPage(),
          routes: {
            '/tambah': (ctx) => const FormKegiatanPage(),
          },
        );
      },
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HariIniTab(),
    LaporanTab(),
    PengaturanTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ---------------- TAB 1: HARI INI ----------------
class HariIniTab extends StatefulWidget {
  const HariIniTab({super.key});

  @override
  State<HariIniTab> createState() => _HariIniTabState();
}

class _HariIniTabState extends State<HariIniTab> {
  final String _hariIni = FormatHelper.tanggalSekarang();
  late Future<List<Kegiatan>> _futureKegiatan;
  late Future<Ringkasan> _futureRingkasan;

  @override
  void initState() {
    super.initState();
    _muatData();
    versiData.addListener(_muatData);
  }

  @override
  void dispose() {
    versiData.removeListener(_muatData);
    super.dispose();
  }

  void _muatData() {
    setState(() {
      _futureKegiatan = DbHelper.pada(_hariIni);
      _futureRingkasan = DbHelper.ringkasan(_hariIni);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hari Ini'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Kartu Ringkasan
          FutureBuilder<Ringkasan>(
            future: _futureRingkasan,
            builder: (context, snap) {
              final r = snap.data ?? Ringkasan.kosong;
              final target = targetTabunganNotifier.value;
              final rasio = target > 0 ? (r.tabungan / target).clamp(0.0, 1.0) : 0.0;
              final bool tekor = r.tabungan < 0;
              final bool tercapai = r.tabungan >= target && target > 0;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(FormatHelper.tanggalIndo(_hariIni),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Selesai: ${r.selesai}/${r.jumlahKegiatan}'),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Pemasukan', style: TextStyle(color: Colors.grey)),
                              Text('+ ${FormatHelper.rupiah(r.pemasukan)}',
                                  style: const TextStyle(
                                      color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.grey)),
                              Text('- ${FormatHelper.rupiah(r.pengeluaran)}',
                                  style: const TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Tabungan', style: TextStyle(color: Colors.grey)),
                              Text(FormatHelper.rupiah(r.tabungan),
                                  style: TextStyle(
                                      color: tekor ? Colors.red : Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: rasio),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, val, _) => LinearProgressIndicator(
                            value: val,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              tekor ? Colors.red : (tercapai ? Colors.green : Colors.indigo),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tekor
                            ? '⚠️ Tabungan negatif! Pengeluaran melebihi pemasukan.'
                            : (tercapai
                                ? '🎉 Selamat! Target harian (${FormatHelper.rupiah(target)}) tercapai.'
                                : 'Target: ${FormatHelper.rupiah(target)}'),
                        style: TextStyle(
                          fontSize: 12,
                          color: tekor ? Colors.red : (tercapai ? Colors.green[800] : Colors.grey),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text('Daftar Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          FutureBuilder<List<Kegiatan>>(
            future: _futureKegiatan,
            builder: (context, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada kegiatan. Ketuk + untuk menambah.')),
                );
              }
              return Column(
                children: list.map((k) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: k.selesai,
                        onChanged: (val) async {
                          await DbHelper.ubah(k.copyWith(selesai: val ?? false));
                        },
                      ),
                      title: Text(
                        k.judul,
                        style: TextStyle(
                          decoration: k.selesai ? TextDecoration.lineThrough : null,
                          color: k.selesai ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        k.tipe == Tipe.tanpa
                            ? 'Tidak ada transaksi uang'
                            : '${k.tipe.name.toUpperCase()}: ${FormatHelper.rupiah(k.nominal)} (${k.kategori})',
                        style: TextStyle(
                          color: k.tipe == Tipe.pemasukan
                              ? Colors.green
                              : (k.tipe == Tipe.pengeluaran ? Colors.red : Colors.grey),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => FormKegiatanPage(kegiatanEdit: k),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus Kegiatan'),
                                  content: Text('Hapus "${k.judul}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Batal')),
                                    FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Hapus')),
                                  ],
                                ),
                              );
                              if (confirm == true && k.id != null) {
                                await DbHelper.hapus(k.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/tambah'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- TAB 2: LAPORAN ----------------
class LaporanTab extends StatefulWidget {
  const LaporanTab({super.key});

  @override
  State<LaporanTab> createState() => _LaporanTabState();
}

class _LaporanTabState extends State<LaporanTab> {
  String _tanggalDipilih = FormatHelper.tanggalSekarang();

  @override
  void initState() {
    super.initState();
    versiData.addListener(_refresh);
  }

  @override
  void dispose() {
    versiData.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _pilihTanggal() async {
    final cur = DateTime.tryParse(_tanggalDipilih) ?? DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: cur,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (hasil != null) {
      setState(() {
        final y = hasil.year.toString().padLeft(4, '0');
        final m = hasil.month.toString().padLeft(2, '0');
        final d = hasil.day.toString().padLeft(2, '0');
        _tanggalDipilih = '$y-$m-$d';
      });
    }
  }

  Future<Map<String, int>> _ambilPerKategori(String tanggal) async {
    final db = await DbHelper.database;
    final res = await db.rawQuery('''
      SELECT kategori, SUM(nominal) as total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
    ''', [tanggal]);

    final Map<String, int> map = {};
    for (final r in res) {
      map[r['kategori'] as String] = (r['total'] as int?) ?? 0;
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> _ambil7Hari() async {
    final List<Map<String, dynamic>> riwayat = [];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final tglDate = now.subtract(Duration(days: i));
      final y = tglDate.year.toString().padLeft(4, '0');
      final m = tglDate.month.toString().padLeft(2, '0');
      final d = tglDate.day.toString().padLeft(2, '0');
      final tglStr = '$y-$m-$d';

      final ringkas = await DbHelper.ringkasan(tglStr);
      riwayat.add({
        'tanggal': tglStr,
        'ringkasan': ringkas,
      });
    }
    return riwayat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pilihTanggal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: const Text('Tanggal Laporan:'),
              subtitle: Text(FormatHelper.tanggalIndo(_tanggalDipilih),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: ElevatedButton(
                onPressed: _pilihTanggal,
                child: const Text('Ubah Tanggal'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Ringkasan>(
            future: DbHelper.ringkasan(_tanggalDipilih),
            builder: (context, snap) {
              final r = snap.data ?? Ringkasan.kosong;
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Ringkasan Hari Terpilih',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Pemasukan'),
                              Text(FormatHelper.rupiah(r.pemasukan),
                                  style: const TextStyle(
                                      color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Pengeluaran'),
                              Text(FormatHelper.rupiah(r.pengeluaran),
                                  style: const TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Tabungan'),
                              Text(FormatHelper.rupiah(r.tabungan),
                                  style: TextStyle(
                                      color: r.tabungan < 0 ? Colors.red : Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Pengeluaran per Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          FutureBuilder<Map<String, int>>(
            future: _ambilPerKategori(_tanggalDipilih),
            builder: (context, snap) {
              final map = snap.data ?? {};
              if (map.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada transaksi pengeluaran pada tanggal ini.'),
                  ),
                );
              }
              return Column(
                children: map.entries.map((e) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.pie_chart_outline, color: Colors.orange),
                      title: Text(e.key),
                      trailing: Text(
                        FormatHelper.rupiah(e.value),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Riwayat 7 Hari Terakhir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _ambil7Hari(),
            builder: (context, snap) {
              final list = snap.data ?? [];
              return Column(
                children: list.map((item) {
                  final String tgl = item['tanggal'];
                  final Ringkasan rk = item['ringkasan'];
                  return Card(
                    child: ListTile(
                      title: Text(FormatHelper.tanggalIndo(tgl)),
                      subtitle: Text(
                          'Masuk: ${FormatHelper.rupiah(rk.pemasukan)} | Keluar: ${FormatHelper.rupiah(rk.pengeluaran)}'),
                      trailing: Text(
                        FormatHelper.rupiah(rk.tabungan),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rk.tabungan < 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- TAB 3: PENGATURAN ----------------
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  Future<void> _setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> _setSeedColor(Color c) async {
    seedColorNotifier.value = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', c.value);
  }

  Future<void> _setTarget(int val) async {
    targetTabunganNotifier.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetTabungan', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Target Tabungan Harian', style: TextStyle(fontWeight: FontWeight.bold)),
          ValueListenableBuilder<int>(
            valueListenable: targetTabunganNotifier,
            builder: (context, target, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target saat ini: ${FormatHelper.rupiah(target)}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue)),
                  Slider(
                    value: target.toDouble().clamp(5000.0, 100000.0),
                    min: 5000.0,
                    max: 100000.0,
                    divisions: 19,
                    label: FormatHelper.rupiah(target),
                    onChanged: (v) => _setTarget(v.toInt()),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          const Text('Mode Tampilan (Tema)', style: TextStyle(fontWeight: FontWeight.bold)),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) {
              return SwitchListTile(
                title: const Text('Mode Gelap'),
                subtitle: Text(mode == ThemeMode.dark ? 'Aktif' : 'Nonaktif'),
                value: mode == ThemeMode.dark,
                onChanged: (aktif) {
                  _setThemeMode(aktif ? ThemeMode.dark : ThemeMode.light);
                },
              );
            },
          ),
          const Divider(height: 32),
          const Text('Pilihan Warna Tema', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ValueListenableBuilder<Color>(
            valueListenable: seedColorNotifier,
            builder: (context, curColor, _) {
              return Wrap(
                spacing: 12,
                children: daftarPilihanWarna.entries.map((e) {
                  final isSelected = curColor.value == e.value.value;
                  return ChoiceChip(
                    label: Text(e.key),
                    selected: isSelected,
                    avatar: CircleAvatar(backgroundColor: e.value),
                    onSelected: (_) => _setSeedColor(e.value),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

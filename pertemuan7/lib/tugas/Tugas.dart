import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../praktikum/BagianA.dart';
import '../praktikum/BagianC.dart';

// Entry point jika Tugas.dart dijalankan mandiri
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final modeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
  tabungKuThemeMode.value = ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)];

  final colorVal = prefs.getInt('seedColor');
  if (colorVal != null) tabungKuSeedColor.value = Color(colorVal);

  final targetVal = prefs.getInt('targetTabungan') ?? 20000;
  tabungKuTargetTabungan.value = targetVal;

  runApp(const TabungKuApp());
}

final ValueNotifier<ThemeMode> tabungKuThemeMode = ValueNotifier(ThemeMode.system);
final ValueNotifier<Color> tabungKuSeedColor = ValueNotifier(Colors.indigo);
final ValueNotifier<int> tabungKuTargetTabungan = ValueNotifier(20000);

final Map<String, Color> koleksiWarna = {
  'Indigo': Colors.indigo,
  'Teal': Colors.teal,
  'Oranye': Colors.deepOrange,
  'Pink': Colors.pink,
  'Emerald': Colors.green,
};

class TabungKuApp extends StatelessWidget {
  const TabungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([tabungKuThemeMode, tabungKuSeedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TabungKu',
          debugShowCheckedModeBanner: false,
          themeMode: tabungKuThemeMode.value,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: tabungKuSeedColor.value,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: tabungKuSeedColor.value,
            brightness: Brightness.dark,
          ),
          home: const TabungKuShellPage(),
          routes: {
            '/tambah': (ctx) => const FormKegiatanPage(),
          },
        );
      },
    );
  }
}

class TabungKuShellPage extends StatefulWidget {
  const TabungKuShellPage({super.key});

  @override
  State<TabungKuShellPage> createState() => _TabungKuShellPageState();
}

class _TabungKuShellPageState extends State<TabungKuShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TabungKuHariIniView(),
    TabungKuLaporanView(),
    TabungKuPengaturanView(),
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
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ---------------- 1. TAB HARI INI ----------------
class TabungKuHariIniView extends StatefulWidget {
  const TabungKuHariIniView({super.key});

  @override
  State<TabungKuHariIniView> createState() => _TabungKuHariIniViewState();
}

class _TabungKuHariIniViewState extends State<TabungKuHariIniView> {
  final String _hariIni = FormatHelper.tanggalSekarang();
  late Future<List<Kegiatan>> _futureKegiatan;
  late Future<Ringkasan> _futureRingkasan;

  @override
  void initState() {
    super.initState();
    _load();
    versiData.addListener(_load);
  }

  @override
  void dispose() {
    versiData.removeListener(_load);
    super.dispose();
  }

  void _load() {
    setState(() {
      _futureKegiatan = DbHelper.pada(_hariIni);
      _futureRingkasan = DbHelper.ringkasan(_hariIni);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabungKu — Hari Ini'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ValueListenableBuilder<int>(
            valueListenable: tabungKuTargetTabungan,
            builder: (context, target, _) {
              return FutureBuilder<Ringkasan>(
                future: _futureRingkasan,
                builder: (context, snap) {
                  final r = snap.data ?? Ringkasan.kosong;
                  final tekor = r.tabungan < 0;
                  final tercapai = r.tabungan >= target && target > 0;
                  final progress = target > 0 ? (r.tabungan / target).clamp(0.0, 1.0) : 0.0;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: tekor
                            ? Colors.red.shade300
                            : (tercapai ? Colors.green.shade300 : Colors.transparent),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    FormatHelper.tanggalIndo(_hariIni),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text('Selesai: ${r.selesai}/${r.jumlahKegiatan}'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Pemasukan',
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+ ${FormatHelper.rupiah(r.pemasukan)}',
                                    style: const TextStyle(
                                        color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Pengeluaran',
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '- ${FormatHelper.rupiah(r.pengeluaran)}',
                                    style: const TextStyle(
                                        color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Tabungan',
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    FormatHelper.rupiah(r.tabungan),
                                    style: TextStyle(
                                      color: tekor ? Colors.red : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: progress),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                minHeight: 10,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  tekor ? Colors.red : (tercapai ? Colors.green : Colors.indigo),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: tekor
                                  ? Colors.red.withOpacity(0.1)
                                  : (tercapai
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tekor
                                      ? Icons.warning_amber
                                      : (tercapai ? Icons.verified : Icons.flag),
                                  size: 16,
                                  color: tekor
                                      ? Colors.red
                                      : (tercapai ? Colors.green : Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tekor
                                        ? 'Peringatan: Tabungan negatif! Pengeluaran lebih besar dari pemasukan.'
                                        : (tercapai
                                            ? 'Hebat! Anda mencapai target menabung hari ini (${FormatHelper.rupiah(target)})!'
                                            : 'Target menabung: ${FormatHelper.rupiah(target)}'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: tekor
                                          ? Colors.red
                                          : (tercapai ? Colors.green.shade800 : null),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Kegiatan Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Kegiatan>>(
            future: _futureKegiatan,
            builder: (context, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.checklist, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Tidak ada kegiatan hari ini.'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/tambah'),
                          icon: const Icon(Icons.add),
                          label: const Text('Buat Kegiatan Pertama'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: list.map((k) {
                  return Card(
                    elevation: 1,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        k.tipe == Tipe.tanpa
                            ? 'Tidak melibatkan uang'
                            : '${k.tipe == Tipe.pemasukan ? "+" : "-"} ${FormatHelper.rupiah(k.nominal)} (${k.kategori})',
                        style: TextStyle(
                          color: k.tipe == Tipe.pemasukan
                              ? Colors.green.shade700
                              : (k.tipe == Tipe.pengeluaran ? Colors.red.shade700 : Colors.grey),
                          fontWeight: k.tipe == Tipe.tanpa ? null : FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
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
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            onPressed: () async {
                              final hapus = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text('Hapus kegiatan "${k.judul}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Batal')),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style:
                                          FilledButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (hapus == true && k.id != null) {
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

// ---------------- 2. TAB LAPORAN ----------------
class TabungKuLaporanView extends StatefulWidget {
  const TabungKuLaporanView({super.key});

  @override
  State<TabungKuLaporanView> createState() => _TabungKuLaporanViewState();
}

class _TabungKuLaporanViewState extends State<TabungKuLaporanView> {
  String _selectedTanggal = FormatHelper.tanggalSekarang();

  @override
  void initState() {
    super.initState();
    versiData.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    versiData.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pilihTanggal() async {
    final cur = DateTime.tryParse(_selectedTanggal) ?? DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: cur,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (res != null) {
      setState(() {
        final y = res.year.toString().padLeft(4, '0');
        final m = res.month.toString().padLeft(2, '0');
        final d = res.day.toString().padLeft(2, '0');
        _selectedTanggal = '$y-$m-$d';
      });
    }
  }

  Future<Map<String, int>> _getPengeluaranPerKategori(String tgl) async {
    final db = await DbHelper.database;
    final res = await db.rawQuery('''
      SELECT kategori, SUM(nominal) as total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
    ''', [tgl]);

    final Map<String, int> hasil = {};
    for (final r in res) {
      hasil[r['kategori'] as String] = (r['total'] as int?) ?? 0;
    }
    return hasil;
  }

  Future<List<Map<String, dynamic>>> _get7Hari() async {
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
        title: const Text('Laporan & Analitik'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range, color: Colors.blue),
              title: const Text('Tanggal Analisis'),
              subtitle: Text(
                FormatHelper.tanggalIndo(_selectedTanggal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Ringkasan>(
            future: DbHelper.ringkasan(_selectedTanggal),
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
                              const Text('Pemasukan', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('+ ${FormatHelper.rupiah(r.pemasukan)}',
                                  style: const TextStyle(
                                      color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('- ${FormatHelper.rupiah(r.pengeluaran)}',
                                  style: const TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Tabungan Bersih',
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
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
          const Text('Pengeluaran Berdasarkan Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          FutureBuilder<Map<String, int>>(
            future: _getPengeluaranPerKategori(_selectedTanggal),
            builder: (context, snap) {
              final map = snap.data ?? {};
              if (map.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Tidak ada transaksi pengeluaran pada tanggal ini.'),
                    ),
                  ),
                );
              }
              return Column(
                children: map.entries.map((e) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.shopping_bag_outlined),
                      ),
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            future: _get7Hari(),
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
                        'Masuk: ${FormatHelper.rupiah(rk.pemasukan)} • Keluar: ${FormatHelper.rupiah(rk.pengeluaran)}',
                      ),
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

// ---------------- 3. TAB PENGATURAN ----------------
class TabungKuPengaturanView extends StatelessWidget {
  const TabungKuPengaturanView({super.key});

  Future<void> _setThemeMode(ThemeMode mode) async {
    tabungKuThemeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> _setSeedColor(Color c) async {
    tabungKuSeedColor.value = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', c.value);
  }

  Future<void> _setTarget(int val) async {
    tabungKuTargetTabungan.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetTabungan', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan TabungKu'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Target Tabungan Harian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: tabungKuTargetTabungan,
            builder: (context, target, _) {
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Target Harian:'),
                          Text(
                            FormatHelper.rupiah(target),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      Slider(
                        value: target.toDouble().clamp(5000.0, 100000.0),
                        min: 5000.0,
                        max: 100000.0,
                        divisions: 19,
                        label: FormatHelper.rupiah(target),
                        onChanged: (v) => _setTarget(v.toInt()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Tampilan & Tema',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: tabungKuThemeMode,
            builder: (context, mode, _) {
              return Card(
                elevation: 1,
                child: SwitchListTile(
                  secondary: Icon(
                    mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: const Text('Mode Gelap'),
                  subtitle: Text(mode == ThemeMode.dark ? 'Aktif' : 'Nonaktif'),
                  value: mode == ThemeMode.dark,
                  onChanged: (aktif) {
                    _setThemeMode(aktif ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilihan Warna Utama'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<Color>(
                    valueListenable: tabungKuSeedColor,
                    builder: (context, curColor, _) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: koleksiWarna.entries.map((e) {
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
            ),
          ),
        ],
      ),
    );
  }
}

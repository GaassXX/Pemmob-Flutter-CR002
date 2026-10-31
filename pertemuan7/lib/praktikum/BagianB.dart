import 'package:flutter/material.dart';
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
      judul: 'Contoh Kegiatan ${DateTime.now().second}',
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
        content: Text('Apakah Anda yakin ingin menghapus kegiatan "${item.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true && item.id != null) {
      await DbHelper.hapus(item.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${item.judul}" berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 7 - Bagian B (Hari Ini)'),
      ),
      body: FutureBuilder<List<Kegiatan>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_available, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Belum ada kegiatan hari ini.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _tambahContoh,
                    child: const Text('Tambah Kegiatan Sampel'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final k = list[index];
              return Card(
                elevation: 1,
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
                        ? 'Tanpa Uang'
                        : '${k.tipe.name.toUpperCase()} • ${FormatHelper.rupiah(k.nominal)} (${k.kategori})',
                    style: TextStyle(
                      color: k.tipe == Tipe.pemasukan
                          ? Colors.green[700]
                          : (k.tipe == Tipe.pengeluaran ? Colors.red[700] : Colors.grey),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _konfirmasiHapus(k),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahContoh,
        child: const Icon(Icons.add),
      ),
    );
  }
}

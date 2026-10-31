import 'package:flutter/material.dart';
import 'BagianA.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: BagianCPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class BagianCPage extends StatelessWidget {
  const BagianCPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Praktikum 7 - Bagian C (Form Kegiatan)')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Buka Form Tambah Kegiatan'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const FormKegiatanPage()),
            );
          },
        ),
      ),
    );
  }
}

class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? kegiatanEdit;

  const FormKegiatanPage({super.key, this.kegiatanEdit});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _nominalController;
  late String _tanggal;
  late Tipe _tipe;
  late String _kategori;

  final List<String> _daftarKategori = [
    'Makan',
    'Transport',
    'Belajar',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.kegiatanEdit;
    _judulController = TextEditingController(text: edit?.judul ?? '');
    _nominalController = TextEditingController(
      text: edit != null && edit.nominal > 0 ? edit.nominal.toString() : '',
    );
    _tanggal = edit?.tanggal ?? FormatHelper.tanggalSekarang();
    _tipe = edit?.tipe ?? Tipe.tanpa;
    _kategori = (edit != null && _daftarKategori.contains(edit.kategori))
        ? edit.kategori
        : _daftarKategori.first;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final cur = DateTime.tryParse(_tanggal) ?? DateTime.now();
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
        _tanggal = '$y-$m-$d';
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final nominal = _tipe == Tipe.tanpa
        ? 0
        : (int.tryParse(_nominalController.text.trim()) ?? 0);

    final kategori = _tipe == Tipe.pengeluaran ? _kategori : '-';

    if (widget.kegiatanEdit == null) {
      final baru = Kegiatan(
        judul: _judulController.text.trim(),
        tanggal: _tanggal,
        tipe: _tipe,
        nominal: nominal,
        kategori: kategori,
      );
      await DbHelper.tambah(baru);
    } else {
      final update = widget.kegiatanEdit!.copyWith(
        judul: _judulController.text.trim(),
        tanggal: _tanggal,
        tipe: _tipe,
        nominal: nominal,
        kategori: kategori,
      );
      await DbHelper.ubah(update);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kegiatanEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Kegiatan' : 'Tambah Kegiatan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kegiatan *',
                    hintText: 'Misal: Makan Siang / Freelance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama kegiatan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Tanggal Kegiatan'),
                    subtitle: Text(FormatHelper.tanggalIndo(_tanggal)),
                    trailing: TextButton(
                      onPressed: _pilihTanggal,
                      child: const Text('Pilih'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jenis Transaksi Keuangan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<Tipe>(
                  segments: const [
                    ButtonSegment(
                      value: Tipe.tanpa,
                      label: Text('Tidak'),
                      icon: Icon(Icons.money_off),
                    ),
                    ButtonSegment(
                      value: Tipe.pemasukan,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.arrow_downward, color: Colors.green),
                    ),
                    ButtonSegment(
                      value: Tipe.pengeluaran,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.arrow_upward, color: Colors.red),
                    ),
                  ],
                  selected: {_tipe},
                  onSelectionChanged: (val) {
                    setState(() {
                      _tipe = val.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_tipe != Tipe.tanpa) ...[
                  TextFormField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp) *',
                      hintText: 'Misal: 20000',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (val) {
                      if (_tipe == Tipe.tanpa) return null;
                      if (val == null || val.trim().isEmpty) {
                        return 'Nominal wajib diisi';
                      }
                      final n = int.tryParse(val.trim());
                      if (n == null || n <= 0) {
                        return 'Nominal harus berupa angka lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (_tipe == Tipe.pengeluaran) ...[
                  DropdownButtonFormField<String>(
                    value: _kategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Pengeluaran',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _daftarKategori.map((kat) {
                      return DropdownMenuItem(
                        value: kat,
                        child: Text(kat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _kategori = val);
                    },
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan Kegiatan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

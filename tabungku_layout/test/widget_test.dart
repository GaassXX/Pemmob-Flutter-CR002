import 'package:flutter_test/flutter_test.dart';
import 'package:tabungku_layout/main.dart';

void main() {
  testWidgets('Memverifikasi elemen RingkasanPage tampil dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(const TabungKuApp());

    // Verifikasi judul AppBar
    expect(find.text('Ringkasan Tabungan'), findsOneWidget);

    // Verifikasi elemen kartu tabungan
    expect(find.text('Tabungan Kuliah'), findsOneWidget);
    expect(find.text('Saldo Saat Ini'), findsOneWidget);
    expect(find.text('Rp 3.000.000'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Rp 12.000.000'), findsOneWidget);
    expect(find.text('25,0%'), findsOneWidget);

    // Verifikasi tombol/ikon kategori
    expect(find.text('Menabung'), findsOneWidget);
    expect(find.text('Tarik'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);

    // Verifikasi daftar transaksi
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Menabung Rutin Bulanan'), findsOneWidget);
  });
}

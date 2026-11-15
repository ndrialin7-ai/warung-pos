import 'package:flutter/material.dart';

const batasDiskon = 50000; // belanja >= Rp50.000 diskon 10%
const kategoriList = ['Semua', 'Kopi', 'Minuman', 'Makanan'];

String rp(int n) =>
    'Rp ${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

class MenuItem {
  final String id, nama, kategori, deskripsi;
  final int harga;
  final IconData ikon;
  const MenuItem(this.id, this.nama, this.kategori, this.harga, this.ikon, this.deskripsi);
}

// ===== DUMMY DATA =====
const daftarMenu = [
  MenuItem('m1', 'Kopi Hitam', 'Kopi', 8000, Icons.coffee, 'Kopi robusta seduh tradisional, pahit mantap.'),
  MenuItem('m2', 'Kopi Susu', 'Kopi', 12000, Icons.local_cafe, 'Kopi dengan susu kental manis, manis seimbang.'),
  MenuItem('m3', 'Kopi Tarik', 'Kopi', 10000, Icons.coffee_maker, 'Kopi ditarik hingga berbusa, khas warung Melayu.'),
  MenuItem('m4', 'Teh Tarik', 'Minuman', 9000, Icons.emoji_food_beverage, 'Teh susu hangat dengan busa tebal.'),
  MenuItem('m5', 'Es Jeruk', 'Minuman', 7000, Icons.local_drink, 'Jeruk peras segar dengan es batu.'),
  MenuItem('m6', 'Mie Lendir', 'Makanan', 18000, Icons.ramen_dining, 'Mie kuah kental dengan kuah kacang khas Kepri.'),
  MenuItem('m7', 'Roti Canai', 'Makanan', 10000, Icons.bakery_dining, 'Roti tipis renyah dengan kuah kari.'),
  MenuItem('m8', 'Nasi Lemak', 'Makanan', 15000, Icons.rice_bowl, 'Nasi santan, telur, ikan teri, dan sambal.'),
  MenuItem('m9', 'Otak-otak', 'Makanan', 12000, Icons.fastfood, 'Otak-otak ikan panggang bumbu rempah.'),
  MenuItem('m10', 'Gonggong Rebus', 'Makanan', 20000, Icons.set_meal, 'Siput laut rebus khas Batam dengan sambal.'),
];

class Transaksi {
  final String id;
  final DateTime waktu;
  final List<MapEntry<MenuItem, int>> item;
  final int subtotal, diskon, total, bayar;
  const Transaksi(this.id, this.waktu, this.item, this.subtotal, this.diskon, this.total, this.bayar);
  int get kembali => bayar - total;
}

// ===== STATE (hidup di atas MaterialApp, jadi aman saat rotasi & pindah halaman) =====
class PosState extends ChangeNotifier {
  final Map<String, int> _qty = {};
  final List<Transaksi> riwayat = [];
  String kategori = 'Semua';
  String cari = '';

  int qty(String id) => _qty[id] ?? 0;
  int get totalItem => _qty.values.fold(0, (a, b) => a + b);
  bool get kosong => _qty.isEmpty;

  List<MapEntry<MenuItem, int>> get isiKeranjang => _qty.entries
      .map((e) => MapEntry(daftarMenu.firstWhere((m) => m.id == e.key), e.value))
      .toList();

  int get subtotal => isiKeranjang.fold(0, (s, e) => s + e.key.harga * e.value);
  int get diskon => subtotal >= batasDiskon ? (subtotal * 0.1).round() : 0;
  int get total => subtotal - diskon;

  List<MenuItem> get menuTerfilter => daftarMenu
      .where((m) =>
          (kategori == 'Semua' || m.kategori == kategori) &&
          m.nama.toLowerCase().contains(cari.trim().toLowerCase()))
      .toList();

  void setKategori(String k) { kategori = k; notifyListeners(); }
  void setCari(String c) { cari = c; notifyListeners(); }
  void tambah(String id, [int n = 1]) { _qty[id] = qty(id) + n; notifyListeners(); }
  void kurang(String id) {
    final q = qty(id);
    if (q <= 1) { _qty.remove(id); } else { _qty[id] = q - 1; }
    notifyListeners();
  }
  void kosongkan() { _qty.clear(); notifyListeners(); }

  Transaksi checkout(int bayar) {
    if (kosong) throw StateError('Keranjang masih kosong');
    if (bayar < total) throw StateError('Uang kurang ${rp(total - bayar)}');
    final t = Transaksi(
      'TRX-${(riwayat.length + 1).toString().padLeft(3, '0')}',
      DateTime.now(), isiKeranjang, subtotal, diskon, total, bayar,
    );
    riwayat.insert(0, t);
    _qty.clear();
    notifyListeners();
    return t;
  }
}
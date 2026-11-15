import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data.dart';

// ===== Helper =====
void _go(BuildContext c, Widget w) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => w));

void _snack(BuildContext c, String msg, {bool error = false}) {
  final cs = Theme.of(c).colorScheme;
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? cs.error : null,
      content: Text(msg, style: TextStyle(color: error ? cs.onError : null)),
    ));
}

Future<bool> _konfirmasi(BuildContext c, String judul, String isi) async {
  final ok = await showDialog<bool>(
    context: c,
    builder: (ctx) => AlertDialog(
      title: Text(judul),
      content: Text(isi),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya')),
      ],
    ),
  );
  return ok ?? false;
}

class _Kosong extends StatelessWidget {
  final IconData ikon;
  final String teks;
  const _Kosong(this.ikon, this.teks);
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(ikon, size: 72, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(teks, style: Theme.of(context).textTheme.titleMedium),
        ]),
      );
}

class _Baris extends StatelessWidget {
  final String label, nilai;
  final bool tebal;
  const _Baris(this.label, this.nilai, {this.tebal = false});
  @override
  Widget build(BuildContext context) {
    final st = tebal
        ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: st), Text(nilai, style: st)]),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  const QtyStepper({super.key, required this.qty, required this.onMinus, required this.onPlus});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton.outlined(tooltip: 'Kurangi', icon: const Icon(Icons.remove), onPressed: onMinus),
        SizedBox(
          width: 32,
          child: Center(child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        IconButton.filled(tooltip: 'Tambah', icon: const Icon(Icons.add), onPressed: onPlus),
      ]);
}

// ===== 1. SPLASH =====
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_cafe, size: 96, color: cs.onPrimary),
          const SizedBox(height: 16),
          Text('Warung Kopi Batam',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
          Text('Kasir sederhana untuk UMKM', style: TextStyle(color: cs.onPrimary)),
          const SizedBox(height: 24),
          CircularProgressIndicator(color: cs.onPrimary),
        ]),
      ),
    );
  }
}

// ===== 2. LOGIN =====
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _sembunyi = true;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _masuk() {
    if (!_form.currentState!.validate()) return;
    if (_user.text.trim() == 'kasir' && _pass.text == '1234') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
    } else {
      _snack(context, 'Username atau password salah', error: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_cafe, size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Masuk Kasir', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _user,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      obscureText: _sembunyi,
                      onFieldSubmitted: (_) => _masuk(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          tooltip: _sembunyi ? 'Tampilkan password' : 'Sembunyikan password',
                          icon: Icon(_sembunyi ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _sembunyi = !_sembunyi),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password wajib diisi';
                        if (v.length < 4) return 'Password minimal 4 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: _masuk, child: const Text('MASUK')),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

// ===== 3. MENU (DASHBOARD) =====
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _keluar(BuildContext c) async {
    if (await _konfirmasi(c, 'Keluar?', 'Keranjang yang belum dibayar akan dikosongkan.')) {
      if (!c.mounted) return;
      c.read<PosState>().kosongkan();
      Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<PosState>();
    final list = s.menuTerfilter;
    return Scaffold(
      appBar: AppBar(title: const Text('Menu'), actions: [
        IconButton(tooltip: 'Riwayat transaksi', icon: const Icon(Icons.receipt_long), onPressed: () => _go(context, const HistoryScreen())),
        IconButton(
          tooltip: 'Keranjang',
          icon: Badge(isLabelVisible: s.totalItem > 0, label: Text('${s.totalItem}'), child: const Icon(Icons.shopping_cart)),
          onPressed: () => _go(context, const CartScreen()),
        ),
        IconButton(tooltip: 'Keluar', icon: const Icon(Icons.logout), onPressed: () => _keluar(context)),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: s.setCari,
            decoration: const InputDecoration(hintText: 'Cari menu...', prefixIcon: Icon(Icons.search)),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final k in kategoriList)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(label: Text(k), selected: s.kategori == k, onSelected: (_) => s.setKategori(k)),
                ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const _Kosong(Icons.search_off, 'Menu tidak ditemukan')
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 480, mainAxisExtent: 88, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _MenuCard(list[i]),
                ),
        ),
      ]),
      bottomNavigationBar: s.kosong
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('Lihat Keranjang • ${s.totalItem} item • ${rp(s.total)}'),
                  onPressed: () => _go(context, const CartScreen()),
                ),
              ),
            ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem m;
  const _MenuCard(this.m);
  @override
  Widget build(BuildContext context) {
    final s = context.watch<PosState>();
    final q = s.qty(m.id);
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _go(context, DetailScreen(m)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: cs.primaryContainer, child: Icon(m.ikon, color: cs.onPrimaryContainer)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                Text(rp(m.harga), style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            q == 0
                ? IconButton.filled(tooltip: 'Tambah ${m.nama}', icon: const Icon(Icons.add), onPressed: () => s.tambah(m.id))
                : QtyStepper(qty: q, onMinus: () => s.kurang(m.id), onPlus: () => s.tambah(m.id)),
          ]),
        ),
      ),
    );
  }
}

// ===== 4. DETAIL ITEM =====
class DetailScreen extends StatefulWidget {
  final MenuItem m;
  const DetailScreen(this.m, {super.key});
  @override
  State<DetailScreen> createState() => _DetailState();
}

class _DetailState extends State<DetailScreen> {
  int n = 1;

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(m.nama)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(radius: 64, backgroundColor: cs.primaryContainer, child: Icon(m.ikon, size: 64, color: cs.onPrimaryContainer)),
              const SizedBox(height: 16),
              Text(m.nama, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Chip(label: Text(m.kategori)),
              Text(rp(m.harga), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(m.deskripsi, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              QtyStepper(qty: n, onMinus: n > 1 ? () => setState(() => n--) : null, onPlus: () => setState(() => n++)),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: Text('Tambah ke Keranjang • ${rp(m.harga * n)}'),
                onPressed: () {
                  context.read<PosState>().tambah(m.id, n);
                  _snack(context, '${m.nama} x$n ditambahkan');
                  Navigator.pop(context);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ===== 5. KERANJANG =====
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<PosState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang'), actions: [
        if (!s.kosong)
          IconButton(
            tooltip: 'Kosongkan keranjang',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              if (await _konfirmasi(context, 'Kosongkan keranjang?', 'Semua pesanan akan dihapus.')) s.kosongkan();
            },
          ),
      ]),
      body: s.kosong
          ? const _Kosong(Icons.shopping_cart_outlined, 'Keranjang masih kosong')
          : Column(children: [
              Expanded(
                child: ListView.separated(
                  itemCount: s.isiKeranjang.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = s.isiKeranjang[i];
                    return ListTile(
                      title: Text(e.key.nama),
                      subtitle: Text('${rp(e.key.harga)} x ${e.value} = ${rp(e.key.harga * e.value)}'),
                      trailing: QtyStepper(qty: e.value, onMinus: () => s.kurang(e.key.id), onPlus: () => s.tambah(e.key.id)),
                    );
                  },
                ),
              ),
              Material(
                elevation: 8,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _Baris('Subtotal', rp(s.subtotal)),
                      if (s.diskon > 0)
                        _Baris('Diskon 10%', '- ${rp(s.diskon)}')
                      else
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Tambah ${rp(batasDiskon - s.subtotal)} lagi untuk diskon 10%',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ),
                      const Divider(),
                      _Baris('Total', rp(s.total), tebal: true),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.payments),
                        label: const Text('CHECKOUT'),
                        onPressed: () => _go(context, const CheckoutScreen()),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
    );
  }
}

// ===== 6. CHECKOUT =====
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _bayar = TextEditingController();

  @override
  void dispose() {
    _bayar.dispose();
    super.dispose();
  }

  Future<void> _proses() async {
    if (!_form.currentState!.validate()) return;
    final s = context.read<PosState>();
    try {
      final t = s.checkout(int.parse(_bayar.text));
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Pembayaran Berhasil'),
          content: Text('${t.id}\nTotal: ${rp(t.total)}\nKembalian: ${rp(t.kembali)}'),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('SELESAI'))],
        ),
      );
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } on StateError catch (e) {
      _snack(context, e.message, error: true);
    } catch (_) {
      _snack(context, 'Terjadi kesalahan, silakan coba lagi', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<PosState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _Baris('Jumlah item', '${s.totalItem}'),
                      _Baris('Subtotal', rp(s.subtotal)),
                      _Baris('Diskon', '- ${rp(s.diskon)}'),
                      const Divider(),
                      _Baris('Total bayar', rp(s.total), tebal: true),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bayar,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Uang diterima', prefixText: 'Rp ', prefixIcon: Icon(Icons.payments)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nominal bayar wajib diisi';
                    final n = int.tryParse(v);
                    if (n == null) return 'Masukkan angka yang valid';
                    if (n < s.total) return 'Uang kurang ${rp(s.total - n)}';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  ActionChip(label: const Text('Uang Pas'), onPressed: () => _bayar.text = '${s.total}'),
                  for (final n in [50000, 100000])
                    if (n >= s.total) ActionChip(label: Text(rp(n)), onPressed: () => _bayar.text = '$n'),
                ]),
                const SizedBox(height: 24),
                FilledButton.icon(icon: const Icon(Icons.check), label: const Text('BAYAR'), onPressed: _proses),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== 7. RIWAYAT =====
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _tgl(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final r = context.watch<PosState>().riwayat;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: r.isEmpty
          ? const _Kosong(Icons.receipt_long, 'Belum ada transaksi')
          : ListView.builder(
              itemCount: r.length,
              itemBuilder: (_, i) {
                final t = r[i];
                return ExpansionTile(
                  leading: const Icon(Icons.receipt),
                  title: Text('${t.id} • ${rp(t.total)}'),
                  subtitle: Text(_tgl(t.waktu)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  children: [
                    for (final e in t.item) _Baris('${e.key.nama} x${e.value}', rp(e.key.harga * e.value)),
                    if (t.diskon > 0) _Baris('Diskon', '- ${rp(t.diskon)}'),
                    _Baris('Bayar', rp(t.bayar)),
                    _Baris('Kembali', rp(t.kembali)),
                  ],
                );
              },
            ),
    );
  }
}
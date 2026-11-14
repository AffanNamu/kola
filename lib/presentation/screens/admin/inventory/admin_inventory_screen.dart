import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});
  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final _search = TextEditingController();
  String _filter = 'all';
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _adjustStock(BuildContext context, String id, String name, int current) async {
    final controller = TextEditingController(text: current.toString());
    final note = TextEditingController();
    final result = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Update stock', style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(alignment: Alignment.centerLeft, child: Text(name, style: const TextStyle(color: Color(0xFF718076)))),
        const SizedBox(height: 14),
        TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'New stock quantity', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'Adjustment note (optional)', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () { final value = int.tryParse(controller.text); if (value != null && value >= 0) Navigator.pop(ctx, value); }, child: const Text('Save stock'))],
    ));
    final adjustmentNote = note.text.trim();
    controller.dispose(); note.dispose();
    if (result == null) return;
    try {
      await FirebaseFirestore.instance.collection('products').doc(id).update({'stock': result, 'isAvailable': result > 0, 'updatedAt': FieldValue.serverTimestamp(), 'metadata.lastStockAdjustment': {'previous': current, 'next': result, 'note': adjustmentNote}});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    appBar: AppBar(title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).limit(250).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Unable to load inventory: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data!.docs.where((d) => d.data()['isDeleted'] != true).toList();
        final low = products.where((d) => (d.data()['stock'] as num? ?? 0) <= 5 && (d.data()['stock'] as num? ?? 0) > 0).length;
        final out = products.where((d) => (d.data()['stock'] as num? ?? 0) <= 0).length;
        final visible = products.where((d) {
          final data = d.data(); final stock = (data['stock'] as num? ?? 0).toInt();
          if (_filter == 'low' && !(stock > 0 && stock <= 5)) return false;
          if (_filter == 'out' && stock > 0) return false;
          final q = _search.text.trim().toLowerCase();
          return q.isEmpty || (data['name'] ?? '').toString().toLowerCase().contains(q) || (data['sku'] ?? '').toString().toLowerCase().contains(q);
        }).toList();
        return ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFFBFE2C8), size: 28), SizedBox(height: 16),
            Text('Inventory control', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 5), Text('Keep stock accurate, catch low inventory early and protect every order from overselling.', style: TextStyle(color: Color(0xFFD6E7DA), height: 1.4)),
          ])),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: _Stat('SKUs', products.length.toString(), Icons.widgets_outlined, AppColors.primary)),
            const SizedBox(width: 9), Expanded(child: _Stat('Low stock', low.toString(), Icons.warning_amber_rounded, const Color(0xFFB7791F))),
            const SizedBox(width: 9), Expanded(child: _Stat('Out of stock', out.toString(), Icons.remove_shopping_cart_outlined, const Color(0xFFB64B45))),
          ]),
          const SizedBox(height: 18),
          TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Search product or SKU', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          Wrap(spacing: 7, children: [
            _Filter('All stock', _filter == 'all', () => setState(() => _filter = 'all')),
            _Filter('Low stock', _filter == 'low', () => setState(() => _filter = 'low')),
            _Filter('Out of stock', _filter == 'out', () => setState(() => _filter = 'out')),
          ]),
          const SizedBox(height: 17),
          Row(children: [const Text('Stock catalogue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const Spacer(), Text(visible.length.toString() + ' products', style: const TextStyle(color: Color(0xFF78837A), fontSize: 12))]),
          const SizedBox(height: 10),
          if (visible.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(28), child: Text('No matching products found.'))),
          ...visible.map((doc) {
            final p = doc.data(); final stock = (p['stock'] as num? ?? 0).toInt(); final reserved = (p['reservedStock'] as num? ?? 0).toInt(); final available = stock - reserved;
            final lowStock = stock > 0 && stock <= 5; final empty = stock <= 0;
            final image = (p['images'] is List && (p['images'] as List).isNotEmpty) ? (p['images'] as List).first.toString() : '';
            final color = empty ? const Color(0xFFB64B45) : (lowStock ? const Color(0xFFB7791F) : const Color(0xFF16845B));
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFE7ECE7))), child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(13), child: Container(width: 58, height: 62, color: const Color(0xFFF1F4F0), child: image.isEmpty ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF98A39A)) : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((p['name'] ?? 'Unnamed product').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 4), Text('SKU: ' + ((p['sku'] ?? '—').toString()), style: const TextStyle(color: Color(0xFF7C877E), fontSize: 10)),
                const SizedBox(height: 7), Row(children: [Text(stock.toString() + ' on hand', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)), const SizedBox(width: 8), Text(available.toString() + ' available', style: const TextStyle(color: Color(0xFF7C877E), fontSize: 10))]),
              ])),
              IconButton(onPressed: () => _adjustStock(context, doc.id, (p['name'] ?? 'Product').toString(), stock), icon: const Icon(Icons.tune_rounded, color: AppColors.primary), tooltip: 'Adjust stock'),
            ]));
          }),
        ]);
      },
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label, value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE7ECE7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 18), const SizedBox(height: 9), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w850)), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF7C877E)))]));
}
class _Filter extends StatelessWidget {
  const _Filter(this.label, this.active, this.onTap); final String label; final bool active; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(label: Text(label), selected: active, onSelected: (_) => onTap(), selectedColor: const Color(0xFFDDEDE0), backgroundColor: Colors.white, labelStyle: TextStyle(color: active ? AppColors.primary : const Color(0xFF68736A), fontWeight: FontWeight.w700), side: BorderSide(color: active ? AppColors.primary : const Color(0xFFE5EAE5)));
}

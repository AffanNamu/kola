import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});
  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  String _filter = 'all';
  Future<void> _openCoupon({String? id, Map<String, dynamic>? existing}) async {
    final code = TextEditingController(text: (existing?['code'] ?? '').toString());
    final description = TextEditingController(text: (existing?['description'] ?? '').toString());
    final amount = TextEditingController(text: (existing?['discountValue'] ?? '').toString());
    final minimum = TextEditingController(text: (existing?['minimumOrderAmount'] ?? '').toString());
    final limit = TextEditingController(text: (existing?['usageLimit'] ?? '0').toString());
    String type = (existing?['discountType'] ?? 'percentage').toString();
    final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
      decoration: const BoxDecoration(color: Color(0xFFF8FAF7), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD6DED6), borderRadius: BorderRadius.circular(5)))),
        const SizedBox(height: 18), Text(id == null ? 'Create promotion' : 'Edit promotion', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5), const Text('Set the offer rules customers will see at checkout.', style: TextStyle(color: Color(0xFF758078), fontSize: 12)),
        const SizedBox(height: 18),
        _Field(controller: code, label: 'Coupon code', hint: 'e.g. WELCOME10', capitalization: TextCapitalization.characters),
        const SizedBox(height: 11), _Field(controller: description, label: 'Description', hint: 'Short customer-facing explanation'),
        const SizedBox(height: 11),
        const Text('Discount type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 7),
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'percentage', label: Text('Percentage'), icon: Icon(Icons.percent)), ButtonSegment(value: 'fixed', label: Text('Fixed amount'), icon: Icon(Icons.payments_outlined))], selected: {type}, onSelectionChanged: (v) => setSheet(() => type = v.first)),
        const SizedBox(height: 11), _Field(controller: amount, label: type == 'percentage' ? 'Discount percentage' : 'Discount amount', hint: type == 'percentage' ? '10' : '500', numeric: true),
        const SizedBox(height: 11), _Field(controller: minimum, label: 'Minimum order amount (optional)', hint: '0', numeric: true),
        const SizedBox(height: 11), _Field(controller: limit, label: 'Total usage limit (0 = unlimited)', hint: '0', numeric: true),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () async {
          final value = double.tryParse(amount.text.trim()); final min = double.tryParse(minimum.text.trim()); final maxUses = int.tryParse(limit.text.trim());
          if (code.text.trim().isEmpty || value == null || value <= 0 || (type == 'percentage' && value > 100) || maxUses == null) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a valid code, discount and usage limit.'))); return;
          }
          final payload = {'code': code.text.trim().toUpperCase(), 'description': description.text.trim(), 'discountType': type, 'discountValue': value, 'minimumOrderAmount': min, 'usageLimit': maxUses, 'usageCount': existing?['usageCount'] ?? 0, 'perUserLimit': existing?['perUserLimit'] ?? 1, 'isActive': existing?['isActive'] ?? true, 'createdAt': existing?['createdAt'] ?? FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()};
          try {
            final collection = FirebaseFirestore.instance.collection('coupons');
            final couponId = id ?? code.text.trim().toUpperCase();
            if (id == null) { await collection.doc(couponId).set(payload); } else { await collection.doc(couponId).update(payload); }
            await const AdminAuditFirestore().log(action: id == null ? 'coupon_created' : 'coupon_updated', targetUid: couponId, details: {'code': code.text.trim().toUpperCase()});
            if (ctx.mounted) Navigator.pop(ctx, true);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Could not save coupon: $e'))); }
        }, icon: const Icon(Icons.check_rounded), label: Text(id == null ? 'Create coupon' : 'Save changes'))),
      ])),
    )));
    code.dispose(); description.dispose(); amount.dispose(); minimum.dispose(); limit.dispose();
    if (result == true && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promotion saved')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    appBar: AppBar(title: const Text('Promotions', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent, actions: [IconButton(onPressed: () => _openCoupon(), icon: const Icon(Icons.add_circle_outline), tooltip: 'Create coupon')]),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _openCoupon(), backgroundColor: AppColors.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('New promotion')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('coupons').orderBy('createdAt', descending: true).limit(100).snapshots(), builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text('Could not load coupons: ${snapshot.error}'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snapshot.data!.docs;
      final active = docs.where((d) => d.data()['isActive'] == true).length;
      final filtered = docs.where((d) => _filter == 'all' || (_filter == 'active' ? d.data()['isActive'] == true : d.data()['isActive'] != true)).toList();
      return ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 100), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.local_offer_outlined, color: Color(0xFFBFE2C8), size: 28), SizedBox(height: 17),
          Text('Make every offer count.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: 5), Text('Launch targeted discounts, reward loyal shoppers and control promotion usage.', style: TextStyle(color: Color(0xFFD6E7DA), height: 1.4)),
        ])),
        const SizedBox(height: 15),
        Row(children: [Expanded(child: _CountCard('Total offers', docs.length.toString(), Icons.sell_outlined)), const SizedBox(width: 10), Expanded(child: _CountCard('Live offers', active.toString(), Icons.bolt_outlined))]),
        const SizedBox(height: 17),
        Wrap(spacing: 8, children: [_Filter('All', _filter == 'all', () => setState(() => _filter = 'all')), _Filter('Active', _filter == 'active', () => setState(() => _filter = 'active')), _Filter('Paused', _filter == 'paused', () => setState(() => _filter = 'paused'))]),
        const SizedBox(height: 15),
        if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(35), child: Center(child: Text('No promotions yet. Create your first offer.'))),
        ...filtered.map((doc) {
          final p = doc.data(); final enabled = p['isActive'] == true; final percent = p['discountType'] == 'percentage'; final value = (p['discountValue'] as num? ?? 0).toString();
          return Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE6ECE6))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE8F2EA), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary)),
              const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((p['code'] ?? doc.id).toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 3), Text((p['description'] ?? 'Promotion offer').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7A857C), fontSize: 11))])),
              Text(percent ? value + '%' : value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ]),
            const SizedBox(height: 14), Row(children: [
              _Pill(enabled ? 'LIVE' : 'PAUSED', enabled), const SizedBox(width: 8),
              Text('Used ' + (p['usageCount'] ?? 0).toString() + ' / ' + ((p['usageLimit'] ?? 0) == 0 ? '∞' : p['usageLimit'].toString()), style: const TextStyle(color: Color(0xFF778078), fontSize: 11)),
              const Spacer(), IconButton(visualDensity: VisualDensity.compact, onPressed: () => _openCoupon(id: doc.id, existing: p), icon: const Icon(Icons.edit_outlined, size: 19)), Switch.adaptive(value: enabled, onChanged: (v) async { await doc.reference.update({'isActive': v, 'updatedAt': FieldValue.serverTimestamp()}); await const AdminAuditFirestore().log(action: v ? 'coupon_activated' : 'coupon_paused', targetUid: doc.id); }),
            ]),
          ]));
        }),
      ]);
    }),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label, required this.hint, this.numeric = false, this.capitalization = TextCapitalization.none});
  final TextEditingController controller; final String label, hint; final bool numeric; final TextCapitalization capitalization;
  @override
  Widget build(BuildContext context) => TextField(controller: controller, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, textCapitalization: capitalization, decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE1E8E1)))));
}
class _CountCard extends StatelessWidget {
  const _CountCard(this.label, this.value, this.icon); final String label, value; final IconData icon;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))), child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF778078)))])]));
}
class _Filter extends StatelessWidget {
  const _Filter(this.label, this.active, this.onTap); final String label; final bool active; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(label: Text(label), selected: active, onSelected: (_) => onTap(), selectedColor: const Color(0xFFDDEDE0), backgroundColor: Colors.white, labelStyle: TextStyle(color: active ? AppColors.primary : const Color(0xFF68736A), fontWeight: FontWeight.w700));
}
class _Pill extends StatelessWidget {
  const _Pill(this.label, this.active); final String label; final bool active;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: active ? const Color(0xFFE5F4E9) : const Color(0xFFFFF2DF), borderRadius: BorderRadius.circular(30)), child: Text(label, style: TextStyle(color: active ? const Color(0xFF187447) : const Color(0xFF9A671A), fontSize: 9, fontWeight: FontWeight.w900)));
}

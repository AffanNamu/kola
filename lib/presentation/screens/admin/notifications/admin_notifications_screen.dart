import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _audience = 'active';
  String _type = 'promotion';
  bool _sending = false;

  @override
  void dispose() { _title.dispose(); _body.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title and message first.'))); return;
    }
    setState(() => _sending = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'customer');
      if (_audience == 'active') query = query.where('isActive', isEqualTo: true);
      final users = await query.limit(450).get();
      if (users.docs.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No matching customers found.')));
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      final now = FieldValue.serverTimestamp();
      for (final user in users.docs) {
        final ref = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(ref, {'userId': user.id, 'title': _title.text.trim(), 'body': _body.text.trim(), 'type': _type, 'isRead': false, 'createdAt': now, 'data': {'source': 'admin_broadcast'}});
      }
      await batch.commit();
      await FirebaseFirestore.instance.collection('adminBroadcasts').add({'title': _title.text.trim(), 'body': _body.text.trim(), 'type': _type, 'audience': _audience, 'recipientCount': users.docs.length, 'createdBy': FirebaseAuth.instance.currentUser?.uid, 'createdAt': now, 'delivery': 'in_app'});
      await const AdminAuditFirestore().log(action: 'customer_broadcast_sent', details: {'recipientCount': users.docs.length, 'type': _type});
      _title.clear(); _body.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('In-app notification delivered to ${users.docs.length} customers.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification could not be delivered: $e')));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    appBar: AppBar(title: const Text('Customer messaging', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.campaign_outlined, color: Color(0xFFBFE2C8), size: 29), SizedBox(height: 17),
        Text('Speak to your community.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        SizedBox(height: 5), Text('Create clear, useful messages for customers, from order updates to exclusive promotions.', style: TextStyle(color: Color(0xFFD6E7DA), height: 1.4)),
      ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFE6ECE6))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Compose message', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w850)),
        const SizedBox(height: 5), const Text('This creates a notification in each selected customer’s in-app inbox.', style: TextStyle(fontSize: 11, color: Color(0xFF778078))),
        const SizedBox(height: 16),
        TextField(controller: _title, maxLength: 70, decoration: _decoration('Notification title', 'A short, clear headline')),
        const SizedBox(height: 10),
        TextField(controller: _body, maxLines: 4, maxLength: 400, decoration: _decoration('Message', 'Write the message customers will receive...')),
        const SizedBox(height: 9),
        const Text('Message category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w750)),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(value: _type, decoration: _decoration('', 'Choose category'), items: const [
          DropdownMenuItem(value: 'promotion', child: Text('Promotion / Offer')),
          DropdownMenuItem(value: 'general', child: Text('General announcement')),
          DropdownMenuItem(value: 'order', child: Text('Order information')),
          DropdownMenuItem(value: 'payment', child: Text('Payment information')),
        ], onChanged: (v) { if (v != null) setState(() => _type = v); }),
        const SizedBox(height: 15),
        const Text('Recipients', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w750)),
        const SizedBox(height: 7),
        _AudienceTile(title: 'Active customers', subtitle: 'Customers whose accounts are currently active', selected: _audience == 'active', onTap: () => setState(() => _audience = 'active')),
        const SizedBox(height: 8),
        _AudienceTile(title: 'All customer accounts', subtitle: 'Includes paused accounts; excludes guests', selected: _audience == 'all', onTap: () => setState(() => _audience = 'all')),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _sending ? null : _send, icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded), label: Text(_sending ? 'Delivering…' : 'Deliver in-app notification'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)))),
      ])),
      const SizedBox(height: 18),
      Row(children: [const Text('Recent broadcasts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w850)), const Spacer(), const Icon(Icons.history, color: Color(0xFF78837A), size: 18)]),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('adminBroadcasts').orderBy('createdAt', descending: true).limit(15).snapshots(), builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Broadcast history unavailable: ${snapshot.error}');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Text('Your sent broadcasts will appear here.', style: TextStyle(color: Color(0xFF778078), fontSize: 12));
        return Column(children: snapshot.data!.docs.map((doc) {
          final d = doc.data(); final time = d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate() : null;
          return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))), child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE8F2EA), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.mark_email_read_outlined, color: AppColors.primary)),
            const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((d['title'] ?? 'Announcement').toString(), style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text((d['recipientCount'] ?? 0).toString() + ' recipients • ' + (d['delivery'] ?? 'in-app').toString(), style: const TextStyle(color: Color(0xFF778078), fontSize: 10))])),
            if (time != null) Text('${time.day}/${time.month}', style: const TextStyle(color: Color(0xFF778078), fontSize: 10)),
          ]));
        }).toList());
      }),
      const SizedBox(height: 10),
      const Text('Note: push notifications are not sent by this screen yet. Push delivery requires a trusted Firebase Cloud Functions sender.', style: TextStyle(color: Color(0xFF8A6A34), fontSize: 11, height: 1.4)),
    ]),
  );

  InputDecoration _decoration(String label, String hint) => InputDecoration(labelText: label.isEmpty ? null : label, hintText: hint, filled: true, fillColor: const Color(0xFFFAFBF9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE1E8E1))));
}

class _AudienceTile extends StatelessWidget {
  const _AudienceTile({required this.title, required this.subtitle, required this.selected, required this.onTap});
  final String title, subtitle; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: selected ? const Color(0xFFEAF3EC) : const Color(0xFFFAFBF9), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5EAE5))), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.primary : const Color(0xFF9AA49B), size: 19), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w750, fontSize: 12)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Color(0xFF778078), fontSize: 10))]))])));
}

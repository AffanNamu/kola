import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';

const _ownerUid = 'L5E8FXohf6Y7HLify4ITu6eMvIZ2';

class AdminCustomerDetailScreen extends StatelessWidget {
  const AdminCustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  Future<void> _setActive(BuildContext context, bool active) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('setCustomerAuthDisabled').call({'uid': customerId, 'disabled': !active});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(active ? 'Customer account enabled in Firebase Authentication' : 'Customer account disabled in Firebase Authentication')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update account: $e')));
    }
  }

  Future<void> _setRole(BuildContext context, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(customerId).update({'role': role, 'updatedAt': FieldValue.serverTimestamp()});
      await const AdminAuditFirestore().log(action: 'customer_role_changed', targetUid: customerId, details: {'role': role});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer role updated')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update role: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(customerId);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(title: const Text('Customer profile', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Unable to load customer: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Customer record not found.'));
          final user = snapshot.data!.data()!;
          final name = (user['displayName'] ?? 'Unnamed customer').toString();
          final email = (user['email'] ?? 'No email').toString();
          final active = user['isActive'] != false && user['isDeleted'] != true;
          final role = (user['role'] ?? 'customer').toString();
          final created = user['createdAt'] is Timestamp ? (user['createdAt'] as Timestamp).toDate() : null;
          return ListView(padding: const EdgeInsets.all(18), children: [
            Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: .16), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800))),
                const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(email, style: const TextStyle(color: Color(0xFFD6E7DA), fontSize: 12))])),
              ]),
              const SizedBox(height: 20),
              Wrap(spacing: 8, children: [_Tag(active ? 'ACCOUNT ACTIVE' : 'ACCOUNT PAUSED', active ? const Color(0xFFBCE8C8) : const Color(0xFFFFD89B)), _Tag(role.toUpperCase(), const Color(0xFFDCEBDF))]),
            ])),
            const SizedBox(height: 16),
            _Section(title: 'Account controls', subtitle: 'Control customer access to the Kola experience', child: Column(children: [
              SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, value: active, activeColor: AppColors.primary, title: const Text('Account access', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(active ? 'This account is currently active' : 'This account is currently deactivated'), onChanged: (value) => _setActive(context, value)),
              const Divider(height: 20),
              Row(children: [const Expanded(child: Text('Account role', style: TextStyle(fontWeight: FontWeight.w700))), DropdownButton<String>(value: ['customer','admin','guest'].contains(role) ? role : 'customer', items: const [DropdownMenuItem(value: 'customer', child: Text('Customer')), DropdownMenuItem(value: 'admin', child: Text('Admin')), DropdownMenuItem(value: 'guest', child: Text('Guest'))], onChanged: FirebaseAuth.instance.currentUser?.uid == _ownerUid ? (value) { if (value != null) _setRole(context, value); } : null)]),
              const SizedBox(height: 8),
              const Text('Role changes require administrator permission. Protect the owner account and never promote an untrusted user.', style: TextStyle(color: Color(0xFF778078), fontSize: 11, height: 1.4)),
            ])),
            const SizedBox(height: 12),
            _Section(title: 'Customer information', subtitle: 'Account details stored in the customer profile', child: Column(children: [
              _Info('Customer ID', customerId), _Info('Email', email), _Info('Phone', (user['phoneNumber'] ?? 'Not provided').toString()), _Info('Email verified', user['isEmailVerified'] == true ? 'Yes' : 'No'), _Info('Joined', created == null ? 'Not available' : '${created.day}/${created.month}/${created.year}'),
            ])),
            const SizedBox(height: 12),
            _Section(title: 'Recent orders', subtitle: 'Orders associated with this customer', child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: customerId).limit(10).snapshots(), builder: (context, orders) {
              if (orders.hasError) return Text('Could not load orders: ${orders.error}');
              if (!orders.hasData) return const LinearProgressIndicator();
              if (orders.data!.docs.isEmpty) return const Text('No orders recorded for this customer.', style: TextStyle(color: Color(0xFF778078)));
              return Column(children: orders.data!.docs.map((doc) { final d = doc.data(); return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary), title: Text((d['orderNumber'] ?? doc.id).toString(), style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text((d['status'] ?? 'unknown').toString()), trailing: Text((d['total'] ?? 0).toString())); }).toList());
            })),
          ]);
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.child});
  final String title, subtitle; final Widget child;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7ECE7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF7A857C))), const SizedBox(height: 13), child]));
}
class _Info extends StatelessWidget {
  const _Info(this.label, this.value); final String label, value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 112, child: Text(label, style: const TextStyle(color: Color(0xFF778078), fontSize: 12))), Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]));
}
class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color); final String label; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withValues(alpha: .45))), child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)));
}

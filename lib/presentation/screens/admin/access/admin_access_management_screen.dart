import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

const _ownerUid = 'L5E8FXohf6Y7HLify4ITu6eMvIZ2';

class AdminAccessManagementScreen extends StatelessWidget {
  const AdminAccessManagementScreen({super.key});

  Future<void> _changeRole(BuildContext context, DocumentSnapshot<Map<String, dynamic>> doc, String role) async {
    if (doc.id == _ownerUid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The Super Admin account is protected.')));
      return;
    }
    try {
      await doc.reference.update({'role': role, 'updatedAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance.collection('adminActivityLogs').add({'actorUid': FirebaseAuth.instance.currentUser?.uid, 'action': 'role_changed', 'targetUid': doc.id, 'details': {'newRole': role}, 'createdAt': FieldValue.serverTimestamp()});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access role updated.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = FirebaseAuth.instance.currentUser?.uid == _ownerUid;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(title: const Text('Access & roles', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
      body: !isOwner ? const Center(child: Text('Only the Super Admin can manage administrator roles.')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('displayName').limit(250).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Unable to load accounts: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final admins = snapshot.data!.docs.where((d) => d.data()['role'] == 'admin').length;
          return ListView(padding: const EdgeInsets.all(18), children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(23)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFBFE2C8), size: 28), SizedBox(height: 16),
              Text('Protect the keys.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              SizedBox(height: 5), Text('Grant the right level of access to trusted people. The owner account cannot be demoted.', style: TextStyle(color: Color(0xFFD6E7DA), fontSize: 12, height: 1.4)),
            ])),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))), child: Row(children: [const Icon(Icons.verified_user_outlined, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(admins.toString() + ' administrator accounts', style: const TextStyle(fontWeight: FontWeight.w800)), const Text('Only Super Admin can change roles', style: TextStyle(color: Color(0xFF778078), fontSize: 10))]))])),
            const SizedBox(height: 17),
            const Text('Account permissions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            ...snapshot.data!.docs.map((doc) {
              final d = doc.data(); final name = (d['displayName'] ?? 'Unnamed user').toString(); final email = (d['email'] ?? doc.id).toString(); final role = (d['role'] ?? 'customer').toString(); final protected = doc.id == _ownerUid;
              return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))), child: Row(children: [
                CircleAvatar(backgroundColor: const Color(0xFFE8F2EA), foregroundColor: AppColors.primary, child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
                const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 3), Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF778078), fontSize: 10)), if (protected) const Text('PERMANENT OWNER', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7))])),
                DropdownButton<String>(value: ['admin','customer','guest'].contains(role) ? role : 'customer', underline: const SizedBox.shrink(), items: const [DropdownMenuItem(value: 'admin', child: Text('Admin')), DropdownMenuItem(value: 'customer', child: Text('Customer')), DropdownMenuItem(value: 'guest', child: Text('Guest'))], onChanged: protected ? null : (v) { if (v != null && v != role) _changeRole(context, doc, v); }),
              ]));
            }),
            const SizedBox(height: 8),
            const Text('Security note: the Firestore rules must restrict role changes to the Super Admin UID. Hiding controls in the app is not a security boundary.', style: TextStyle(color: Color(0xFF8A6A34), fontSize: 11, height: 1.4)),
          ]);
        },
      ),
    );
  }
}

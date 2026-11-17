import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

const _ownerUid = 'L5E8FXohf6Y7HLify4ITu6eMvIZ2';

class AdminAccessManagementScreen extends StatelessWidget {
  const AdminAccessManagementScreen({super.key});

  Future<void> _changeRole(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
    String role, {
    required bool canAssignSuperAdmin,
  }) async {
    if (doc.id == _ownerUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The permanent owner account is protected.')),
      );
      return;
    }
    if (role == 'super_admin' && !canAssignSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only a Super Admin can appoint another Super Admin.')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role updated to ${role.replaceAll('_', ' ')}.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text('Access & roles', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF5F7F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
        builder: (context, accessSnapshot) {
          final currentRole = accessSnapshot.data?.data()?['role'];
          final canAssignSuperAdmin = currentUid == _ownerUid || currentRole == 'super_admin';
          final canManage = canAssignSuperAdmin || currentRole == 'admin';
          if (!canManage) {
            if (accessSnapshot.hasError) {
              return Center(child: Text('Unable to verify administrator access: ${accessSnapshot.error}'));
            }
            if (!accessSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Only a Super Admin can manage administrator roles.'));
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('displayName')
                .limit(250)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Unable to load accounts: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snapshot.data!.docs;
              final admins = users.where((d) =>
                  ['admin', 'super_admin'].contains(d.data()['role'])).length;
              final superAdmins = users.where((d) =>
                  d.data()['role'] == 'super_admin').length;
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF173E2B), Color(0xFF2D6845)],
                      ),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            color: Color(0xFFBFE2C8), size: 28),
                        SizedBox(height: 16),
                        Text('Protect the keys.',
                            style: TextStyle(color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        SizedBox(height: 5),
                        Text(
                          'Admins can promote registered users to Admin. Super Admins can also appoint other Super Admins. The permanent owner account is protected.',
                          style: TextStyle(color: Color(0xFFD6E7DA), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFFE6ECE6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$admins administrator accounts • $superAdmins super admins',
                                  style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text(canAssignSuperAdmin ? 'You can manage Admin and Super Admin roles' : 'You can promote registered users to Admin',
                                  style: TextStyle(color: Color(0xFF778078), fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  const Text('Registered accounts',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  ...users.map((doc) {
                    final data = doc.data();
                    final name = (data['displayName'] ?? 'Unnamed user').toString();
                    final email = (data['email'] ?? doc.id).toString();
                    final role = (data['role'] ?? 'customer').toString();
                    final protected = doc.id == _ownerUid;
                    final isSuperAdmin = role == 'super_admin';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFE6ECE6)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFE8F2EA),
                            foregroundColor: AppColors.primary,
                            child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                const SizedBox(height: 3),
                                Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF778078), fontSize: 10)),
                                if (protected)
                                  const Text('PERMANENT OWNER', style: TextStyle(
                                    color: AppColors.primary, fontSize: 9,
                                    fontWeight: FontWeight.w900, letterSpacing: .7))
                                else if (isSuperAdmin)
                                  const Text('SUPER ADMIN', style: TextStyle(
                                    color: Color(0xFF6655A4), fontSize: 9,
                                    fontWeight: FontWeight.w900, letterSpacing: .7)),
                              ],
                            ),
                          ),
                          DropdownButton<String>(
                            value: (canAssignSuperAdmin
                                    ? ['admin', 'super_admin', 'customer', 'guest']
                                    : ['admin', 'customer', 'guest']).contains(role)
                                ? role : 'customer',
                            underline: const SizedBox.shrink(),
                            items: [
                              const DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              if (canAssignSuperAdmin)
                                const DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                              const DropdownMenuItem(value: 'customer', child: Text('Customer')),
                              const DropdownMenuItem(value: 'guest', child: Text('Guest')),
                            ],
                            onChanged: (protected || (!canAssignSuperAdmin && !['customer', 'guest'].contains(role))) ? null : (value) {
                              if (value != null && value != role) {
                                _changeRole(context, doc, value, canAssignSuperAdmin: canAssignSuperAdmin);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text(
                    'Only registered accounts appear here. Admins can promote customers or guests to Admin. Only Super Admins can appoint another Super Admin.',
                    style: TextStyle(color: Color(0xFF8A6A34), fontSize: 11, height: 1.4),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

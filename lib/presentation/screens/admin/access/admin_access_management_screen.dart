import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

const _ownerUid = 'L5E8FXohf6Y7HLify4ITu6eMvIZ2';

class AdminAccessManagementScreen extends StatefulWidget {
  const AdminAccessManagementScreen({super.key});

  @override
  State<AdminAccessManagementScreen> createState() => _AdminAccessManagementScreenState();
}

class _AdminAccessManagementScreenState extends State<AdminAccessManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  bool _adding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('listRegisteredUsers')
          .call();
      final data = Map<String, dynamic>.from(result.data as Map);
      final users = (data['users'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList()
        ..sort((a, b) => (a['displayName'] ?? a['email'] ?? '')
            .toString().toLowerCase()
            .compareTo((b['displayName'] ?? b['email'] ?? '').toString().toLowerCase()));
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Unable to load registered accounts.';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load registered accounts: $e';
        _loading = false;
      });
    }
  }

  Future<void> _addAdminByEmail() async {
    final emailController = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add an administrator'),
        content: TextField(
          controller: emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          decoration: const InputDecoration(
            labelText: 'Registered email address',
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, emailController.text.trim()),
            child: const Text('Add admin'),
          ),
        ],
      ),
    );
    emailController.dispose();
    if (email == null || email.isEmpty || !mounted) return;

    setState(() => _adding = true);
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('addAdminByEmail')
          .call(<String, dynamic>{'email': email});
      final data = Map<String, dynamic>.from(result.data as Map);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${data['email']} is now an administrator.')),
      );
      await _loadUsers();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not add this administrator.')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user, String role) async {
    final uid = user['uid'].toString();
    if (uid == _ownerUid) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final canAssignSuperAdmin = currentUid == _ownerUid;
    final admins = _users.where((u) => ['admin', 'super_admin'].contains(u['role'])).length;
    final superAdmins = _users.where((u) => u['role'] == 'super_admin').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text('Access & roles', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF5F7F4),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Refresh registered accounts',
            onPressed: _loading ? null : _loadUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFBFE2C8), size: 28),
                        SizedBox(height: 16),
                        Text('Protect the keys.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        SizedBox(height: 5),
                        Text(
                          'Registered Firebase accounts appear below. Add an existing account by email and assign its administrator role.',
                          style: TextStyle(color: Color(0xFFD6E7DA), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$admins administrator accounts • $superAdmins super admins', style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text('${_users.length} registered accounts found', style: const TextStyle(color: Color(0xFF778078), fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _adding ? null : _addAdminByEmail,
                    icon: _adding
                        ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_add_alt_1),
                    label: const Text('Add admin by email'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Registered accounts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_error!, style: const TextStyle(color: Colors.red)),
                          TextButton(onPressed: _loadUsers, child: const Text('Try again')),
                        ],
                      ),
                    )
                  else if (_users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No registered Firebase Authentication accounts were returned. Pull down to refresh or add an existing account by email.'),
                    )
                  else
                    ..._users.map((user) {
                      final uid = user['uid'].toString();
                      final role = (user['role'] ?? 'customer').toString();
                      final name = (user['displayName'] ?? '').toString();
                      final email = (user['email'] ?? '').toString();
                      final protected = uid == _ownerUid;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFE8F2EA),
                              foregroundColor: AppColors.primary,
                              child: Text((name.isNotEmpty ? name : email).isNotEmpty ? (name.isNotEmpty ? name[0] : email[0]).toUpperCase() : '?'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name.isEmpty ? 'Unnamed user' : name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                  const SizedBox(height: 3),
                                  Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF778078), fontSize: 10)),
                                  if (protected) const Text('PERMANENT OWNER', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: (canAssignSuperAdmin ? ['admin', 'super_admin', 'customer', 'guest'] : ['admin', 'customer', 'guest']).contains(role) ? role : 'customer',
                              underline: const SizedBox.shrink(),
                              items: [
                                const DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                if (canAssignSuperAdmin) const DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                                const DropdownMenuItem(value: 'customer', child: Text('Customer')),
                                const DropdownMenuItem(value: 'guest', child: Text('Guest')),
                              ],
                              onChanged: protected || (!canAssignSuperAdmin && role == 'super_admin')
                                  ? null
                                  : (value) {
                                      if (value != null && value != role) _changeRole(user, value);
                                    },
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  const Text(
                    'Only existing Firebase Authentication accounts can be promoted. Super Admin privileges remain restricted to the permanent owner.',
                    style: TextStyle(color: Color(0xFF8A6A34), fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
    );
  }
}

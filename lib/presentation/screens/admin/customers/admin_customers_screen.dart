import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});
  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final _search = TextEditingController();
  String _filter = 'all';
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).limit(200).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _MessageState('Could not load customers', snapshot.error.toString());
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!.docs.where((d) => d.data()['role'] != 'guest').toList();
          final activeCount = all.where((d) => d.data()['isActive'] != false && d.data()['isDeleted'] != true).length;
          final pausedCount = all.length - activeCount;
          final docs = all.where((d) {
            final data = d.data();
            final active = data['isActive'] != false && data['isDeleted'] != true;
            if (_filter == 'active' && !active) return false;
            if (_filter == 'inactive' && active) return false;
            final q = _search.text.trim().toLowerCase();
            return q.isEmpty || (data['displayName'] ?? '').toString().toLowerCase().contains(q) || (data['email'] ?? '').toString().toLowerCase().contains(q) || d.id.toLowerCase().contains(q);
          }).toList();
          return ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.people_alt_outlined, color: Color(0xFFBFE2C8), size: 28), SizedBox(height: 18),
              Text('Know your customers.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 5), Text('Manage access, understand account activity and keep your Kola community healthy.', style: TextStyle(color: Color(0xFFD6E7DA), height: 1.4)),
            ])),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _Metric('Customers', all.length.toString(), Icons.groups_2_outlined, AppColors.primary)),
              const SizedBox(width: 9), Expanded(child: _Metric('Active', activeCount.toString(), Icons.verified_user_outlined, const Color(0xFF16845B))),
              const SizedBox(width: 9), Expanded(child: _Metric('Paused', pausedCount.toString(), Icons.pause_circle_outline, const Color(0xFFB7791F))),
            ]),
            const SizedBox(height: 20),
            TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Search name, email or customer ID', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              _Filter('All', _filter == 'all', () => setState(() => _filter = 'all')),
              _Filter('Active', _filter == 'active', () => setState(() => _filter = 'active')),
              _Filter('Deactivated', _filter == 'inactive', () => setState(() => _filter = 'inactive')),
            ]),
            const SizedBox(height: 18),
            Row(children: [const Text('Customer directory', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const Spacer(), Text(docs.length.toString() + ' records', style: const TextStyle(color: Color(0xFF778078), fontSize: 12))]),
            const SizedBox(height: 10),
            if (docs.isEmpty) const _MessageState('No customers found', 'Try changing the search or filter.'),
            ...docs.map((doc) {
              final data = doc.data();
              final name = (data['displayName'] ?? 'Unnamed customer').toString();
              final email = (data['email'] ?? 'No email address').toString();
              final active = data['isActive'] != false && data['isDeleted'] != true;
              return Container(margin: const EdgeInsets.only(bottom: 9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8EDE8))), child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                leading: CircleAvatar(backgroundColor: const Color(0xFFE8F2EA), foregroundColor: AppColors.primary, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.w800))),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis)),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [_Status(active ? 'Active' : 'Paused', active), const SizedBox(height: 5), const Icon(Icons.chevron_right, size: 18, color: Color(0xFF89938B))]),
                onTap: () => context.push('/admin/customers/' + doc.id),
              ));
            }),
          ]);
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, this.color);
  final String label, value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE8EDE8))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 19), const SizedBox(height: 10), Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778078)))]));
}
class _Filter extends StatelessWidget {
  const _Filter(this.label, this.active, this.onTap);
  final String label; final bool active; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(label: Text(label), selected: active, onSelected: (_) => onTap(), selectedColor: const Color(0xFFDDEDE0), backgroundColor: Colors.white, side: BorderSide(color: active ? AppColors.primary : const Color(0xFFE5EAE5)), labelStyle: TextStyle(color: active ? AppColors.primary : const Color(0xFF667168), fontWeight: FontWeight.w700));
}
class _Status extends StatelessWidget {
  const _Status(this.label, this.active);
  final String label; final bool active;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: active ? const Color(0xFFE5F4E9) : const Color(0xFFFFF2DF), borderRadius: BorderRadius.circular(30)), child: Text(label, style: TextStyle(color: active ? const Color(0xFF187447) : const Color(0xFF9A671A), fontSize: 10, fontWeight: FontWeight.w800)));
}
class _MessageState extends StatelessWidget {
  const _MessageState(this.title, this.detail);
  final String title, detail;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.inbox_outlined, size: 34, color: Color(0xFF9AA49B)), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(detail, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF778078), fontSize: 12))]));
}

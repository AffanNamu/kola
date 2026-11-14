import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminActivityLogsScreen extends StatelessWidget {
  const AdminActivityLogsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    appBar: AppBar(title: const Text('Admin activity', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('adminActivityLogs').orderBy('createdAt', descending: true).limit(100).snapshots(), builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text('Activity history unavailable: ${snapshot.error}'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final logs = snapshot.data!.docs;
      return ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173E2B), Color(0xFF2D6845)]), borderRadius: BorderRadius.circular(23)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.history_rounded, color: Color(0xFFBFE2C8), size: 28), SizedBox(height: 16),
          Text('Every action leaves a trace.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          SizedBox(height: 5), Text('Review sensitive changes made by administrators and keep your store operations accountable.', style: TextStyle(color: Color(0xFFD6E7DA), fontSize: 12, height: 1.4)),
        ])),
        const SizedBox(height: 16),
        Row(children: [const Text('Latest events', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text(logs.length.toString() + ' records', style: const TextStyle(color: Color(0xFF778078), fontSize: 11))]),
        const SizedBox(height: 10),
        if (logs.isEmpty) const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('No admin activity has been recorded yet.', style: TextStyle(color: Color(0xFF778078))))),
        ...logs.map((doc) {
          final d = doc.data(); final action = (d['action'] ?? 'admin_action').toString().replaceAll('_', ' '); final actor = (d['actorUid'] ?? 'Unknown admin').toString(); final target = (d['targetUid'] ?? '').toString(); final time = d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate() : null;
          return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE6))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFE8F2EA), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bolt_outlined, color: AppColors.primary, size: 19)),
            const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(action, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4), Text('By: ' + actor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF778078), fontSize: 10)),
              if (target.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 3), child: Text('Target: ' + target, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF778078), fontSize: 10))),
              if (time != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text('${time.day}/${time.month}/${time.year} • ${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}', style: const TextStyle(color: Color(0xFF8A948B), fontSize: 9))),
            ])),
          ]));
        }),
      ]);
    }),
  );
}

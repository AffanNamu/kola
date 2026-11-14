import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <_Item>[
      _Item('Orders', 'Fulfilment & tracking', Icons.receipt_long_rounded, const Color(0xFFE9F1FF), const Color(0xFF3766A5), () => context.push('/admin/orders')),
      _Item('Customers', 'Profiles & access', Icons.people_alt_rounded, const Color(0xFFE7F4EA), const Color(0xFF28764B), () => context.push('/admin/customers')),
      _Item('Products', 'Catalogue management', Icons.inventory_2_rounded, const Color(0xFFFFF1DF), const Color(0xFFB7791F), () => context.push('/admin/products')),
      _Item('Inventory', 'Stock & availability', Icons.warehouse_rounded, const Color(0xFFEDEBFA), const Color(0xFF6655A4), () => context.push('/admin/inventory')),
      _Item('Payments', 'Verification & history', Icons.account_balance_wallet_rounded, const Color(0xFFE2F4F2), const Color(0xFF267E75), () => context.push(RouteConstants.adminPayments)),
      _Item('Promotions', 'Coupons & discounts', Icons.local_offer_rounded, const Color(0xFFFFE9E7), const Color(0xFFB44D43), () => context.push('/admin/coupons')),
      _Item('Reviews', 'Moderation queue', Icons.reviews_rounded, const Color(0xFFFFF5D9), const Color(0xFF9C741D), () => context.push(RouteConstants.adminReviews)),
      _Item('Messages', 'Customer announcements', Icons.campaign_rounded, const Color(0xFFE8F0F8), const Color(0xFF456C91), () => context.push('/admin/notifications')),
      _Item('Reports', 'Sales & performance', Icons.query_stats_rounded, const Color(0xFFE8F3ED), const Color(0xFF347A56), () => context.push(RouteConstants.adminReports)),
      _Item('Categories', 'Shop organisation', Icons.category_rounded, const Color(0xFFF1EAF7), const Color(0xFF78549A), () => context.push('/admin/categories')),
      _Item('Banners', 'Storefront campaigns', Icons.view_carousel_rounded, const Color(0xFFFFEEDB), const Color(0xFFAA6C27), () => context.push('/admin/banners')),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F4), surfaceTintColor: Colors.transparent,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KOLA COMMERCE', style: TextStyle(fontSize: 10, letterSpacing: 2.1, color: Color(0xFF718076), fontWeight: FontWeight.w800)),
          Text('Admin workspace', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        ]),
        actions: [IconButton(tooltip: 'Open storefront', onPressed: () => context.go('/home'), icon: const Icon(Icons.storefront_outlined)), const SizedBox(width: 7)],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF123A28), Color(0xFF2E6845)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Color(0x24163E2B), blurRadius: 20, offset: Offset(0, 9))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFFD2E9D8))), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(30)), child: const Text('CONTROL CENTRE', style: TextStyle(color: Color(0xFFD2E9D8), fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w900)))]),
          const SizedBox(height: 22),
          const Text('Good business starts\nwith great control.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -.5)),
          const SizedBox(height: 9),
          const Text('Your store operations, customer experience and performance tools — all in one place.', style: TextStyle(color: Color(0xFFD6E7DA), fontSize: 12, height: 1.5)),
        ])),
        const SizedBox(height: 23),
        Row(children: [const Text('Store operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), Text(sections.length.toString() + ' tools', style: const TextStyle(color: Color(0xFF778078), fontSize: 11))]),
        const SizedBox(height: 12),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: sections.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 11, crossAxisSpacing: 11, childAspectRatio: 1.12), itemBuilder: (context, index) {
          final item = sections[index];
          return Material(color: Colors.white, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: item.onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE6ECE6))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 43, height: 43, decoration: BoxDecoration(color: item.tint, borderRadius: BorderRadius.circular(14)), child: Icon(item.icon, color: item.color, size: 21)),
            const Spacer(), Text(item.title, style: const TextStyle(fontWeight: FontWeight.w850, fontSize: 14)), const SizedBox(height: 4), Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7C877E), fontSize: 10)),
            const SizedBox(height: 8), Row(children: [Text('Open workspace', style: TextStyle(color: item.color, fontSize: 10, fontWeight: FontWeight.w800)), const Spacer(), Icon(Icons.arrow_outward_rounded, color: item.color, size: 15)]),
          ]))));
        }),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEAF2EB), borderRadius: BorderRadius.circular(17)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.shield_outlined, color: AppColors.primary, size: 19), SizedBox(width: 10), Expanded(child: Text('Administrator access is protected by Firebase security rules. Only trusted administrators should receive elevated roles.', style: TextStyle(color: Color(0xFF49634F), fontSize: 11, height: 1.4)))])),
      ])),
    );
  }
}

class _Item {
  const _Item(this.title, this.subtitle, this.icon, this.tint, this.color, this.onTap);
  final String title, subtitle; final IconData icon; final Color tint, color; final VoidCallback onTap;
}

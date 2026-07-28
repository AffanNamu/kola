import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/banner/banner_model.dart';
import '../../../data/remote/firestore/banner_firestore.dart';

final bannerFirestoreProvider = Provider<BannerFirestore>((ref) {
  return const BannerFirestore();
});

final activeBannersProvider = StreamProvider<List<BannerModel>>((ref) {
  final fs = ref.read(bannerFirestoreProvider);
  return fs.watchActiveBanners();
});

final adminBannersProvider = StreamProvider<List<BannerModel>>((ref) {
  final fs = ref.read(bannerFirestoreProvider);
  return fs.watchAdminBanners();
});

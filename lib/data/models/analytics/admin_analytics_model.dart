import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_analytics_model.freezed.dart';
part 'admin_analytics_model.g.dart';

@freezed
class AdminAnalyticsModel with _$AdminAnalyticsModel {
  const factory AdminAnalyticsModel({
    @Default(0) int orders30d,
    @Default(0.0) double revenue30d,
    @Default(0) int customers,
    @Default(0) int products,
    @Default([]) List<TopProduct> topProducts,
    @Default('') String updatedAtIso,
  }) = _AdminAnalyticsModel;

  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminAnalyticsModelFromJson(json);
}

@freezed
class TopProduct with _$TopProduct {
  const factory TopProduct({
    required String productId,
    required String name,
    @Default(0) int qty,
  }) = _TopProduct;

  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      _$TopProductFromJson(json);
}

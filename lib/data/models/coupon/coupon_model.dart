import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_model.freezed.dart';
part 'coupon_model.g.dart';

@freezed
class CouponModel with _$CouponModel {
  const factory CouponModel({
    required String id,
    required String code,
    @Default('') String description,
    @Default('percentage') String discountType,
    required double discountValue,
    double? minimumOrderAmount,
    double? maximumDiscount,
    @Default(true) bool isActive,
    @Default(0) int usageLimit,
    @Default(0) int usageCount,
    @Default(1) int perUserLimit,
    @Default([]) List<String> applicableProducts,
    @Default([]) List<String> applicableCategories,
    @Default([]) List<String> usedByUsers,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CouponModel;

  const CouponModel._();

  factory CouponModel.fromJson(Map<String, dynamic> json) =>
      _$CouponModelFromJson(json);

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel.fromJson({
      'id': doc.id,
      ...data,
      'discountValue': (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      'minimumOrderAmount':
          (data['minimumOrderAmount'] as num?)?.toDouble(),
      'maximumDiscount': (data['maximumDiscount'] as num?)?.toDouble(),
      'startDate':
          (data['startDate'] as Timestamp?)?.toDate().toIso8601String(),
      'endDate': (data['endDate'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (startDate != null) json['startDate'] = Timestamp.fromDate(startDate!);
    if (endDate != null) json['endDate'] = Timestamp.fromDate(endDate!);
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    return json;
  }

  bool get isPercentage => discountType == 'percentage';
  bool get isFixed => discountType == 'fixed';

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get hasReachedLimit =>
      usageLimit > 0 && usageCount >= usageLimit;

  bool get isCurrentlyValid =>
      isActive && !isExpired && !hasReachedLimit;

  double calculateDiscount(double orderAmount) {
    if (!isCurrentlyValid) return 0;
    if (minimumOrderAmount != null && orderAmount < minimumOrderAmount!) {
      return 0;
    }
    double discount;
    if (isPercentage) {
      discount = orderAmount * (discountValue / 100);
      if (maximumDiscount != null && discount > maximumDiscount!) {
        discount = maximumDiscount!;
      }
    } else {
      discount = discountValue;
    }
    return discount > orderAmount ? orderAmount : discount;
  }
}

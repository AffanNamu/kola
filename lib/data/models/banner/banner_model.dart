import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
class BannerModel with _$BannerModel {
  const factory BannerModel({
    required String id,
    required String title,
    @Default('') String subtitle,
    required String imageUrl,
    @Default('') String actionUrl,
    @Default('none') String actionType,
    @Default('') String actionValue,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BannerModel;

  const BannerModel._();

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel.fromJson({
      'id': doc.id,
      ...data,
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

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isScheduled {
    if (startDate == null) return false;
    return DateTime.now().isBefore(startDate!);
  }

  bool get isCurrentlyActive => isActive && !isExpired && !isScheduled;
}

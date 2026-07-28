import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String body,
    @Default('general') String type,
    @Default(false) bool isRead,
    @Default({}) Map<String, dynamic> data,
    String? imageUrl,
    String? actionRoute,
    String? actionId,
    DateTime? createdAt,
    DateTime? readAt,
  }) = _NotificationModel;

  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'readAt': (data['readAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    if (readAt != null) json['readAt'] = Timestamp.fromDate(readAt!);
    return json;
  }

  bool get isOrderNotification => type == 'order';
  bool get isPaymentNotification => type == 'payment';
  bool get isPromotionNotification => type == 'promotion';
  bool get isRestockNotification => type == 'restock';
  bool get isPriceDropNotification => type == 'price_drop';
}

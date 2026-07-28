import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required String productId,
    required String userId,
    required String userName,
    @Default('') String userAvatar,
    required double rating,
    required String title,
    required String body,
    @Default([]) List<String> images,
    @Default(false) bool isVerifiedPurchase,
    @Default(false) bool isApproved,
    @Default(false) bool isDeleted,
    @Default(0) int helpfulCount,
    String? orderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ReviewModel;

  const ReviewModel._();

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromJson({
      'id': doc.id,
      ...data,
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    return json;
  }

  int get ratingInt => rating.round();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    @Default('') String displayName,
    @Default('') String phoneNumber,
    @Default('') String photoUrl,
    @Default('customer') String role,
    @Default(false) bool isEmailVerified,
    @Default(true) bool isActive,
    @Default(false) bool isDeleted,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'uid': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid');
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    return json;
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
  bool get isGuest => role == 'guest';

  String get initials {
    if (displayName.isEmpty) return email.substring(0, 1).toUpperCase();
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get firstName {
    if (displayName.isEmpty) return '';
    return displayName.trim().split(' ').first;
  }
}

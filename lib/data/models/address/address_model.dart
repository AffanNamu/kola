import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    @Default('') String addressLine2,
    required String city,
    required String state,
    required String country,
    @Default('') String postalCode,
    @Default(false) bool isDefault,
    @Default('home') String addressType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AddressModel;

  const AddressModel._();

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromJson({
      'id': doc.id,
      ...data,
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

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      state,
      if (postalCode.isNotEmpty) postalCode,
      country,
    ];
    return parts.join(', ');
  }

  String get shortAddress => '$addressLine1, $city, $country';
}

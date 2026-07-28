import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String orderId,
    required String userId,
    required String gateway,
    required String reference,
    @Default('pending') String status,
    required double amount,
    @Default('USD') String currency,
    @Default(false) bool verified,
    String? channel,
    String? cardType,
    String? bankName,
    String? failureReason,
    @Default({}) Map<String, dynamic> gatewayResponse,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
  }) = _PaymentModel;

  const PaymentModel._();

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromJson({
      'id': doc.id,
      ...data,
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'verifiedAt':
          (data['verifiedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    if (verifiedAt != null) {
      json['verifiedAt'] = Timestamp.fromDate(verifiedAt!);
    }
    return json;
  }

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';

  bool get isPaystack => gateway == 'paystack';
  bool get isFlutterwave => gateway == 'flutterwave';
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item_model.dart';
import '../address/address_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String orderNumber,
    required String userId,
    @Default('pending_payment') String status,
    required List<OrderItemModel> items,
    required double subtotal,
    @Default(0.0) double shippingFee,
    @Default(0.0) double discount,
    required double total,
    String? couponCode,
    AddressModel? address,
    String? addressId,
    String? paymentId,
    @Default('') String paymentGateway,
    @Default('') String paymentReference,
    @Default('') String trackingNumber,
    @Default('') String courierName,
    @Default('') String notes,
    @Default('') String cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _OrderModel;

  const OrderModel._();

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson({
      'id': doc.id,
      ...data,
      'subtotal': (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      'shippingFee': (data['shippingFee'] as num?)?.toDouble() ?? 0.0,
      'discount': (data['discount'] as num?)?.toDouble() ?? 0.0,
      'total': (data['total'] as num?)?.toDouble() ?? 0.0,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'paidAt': (data['paidAt'] as Timestamp?)?.toDate().toIso8601String(),
      'confirmedAt':
          (data['confirmedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'shippedAt':
          (data['shippedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'deliveredAt':
          (data['deliveredAt'] as Timestamp?)?.toDate().toIso8601String(),
      'cancelledAt':
          (data['cancelledAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    _convertDateToTimestamp(json, 'createdAt', createdAt);
    _convertDateToTimestamp(json, 'updatedAt', updatedAt);
    _convertDateToTimestamp(json, 'paidAt', paidAt);
    _convertDateToTimestamp(json, 'confirmedAt', confirmedAt);
    _convertDateToTimestamp(json, 'shippedAt', shippedAt);
    _convertDateToTimestamp(json, 'deliveredAt', deliveredAt);
    _convertDateToTimestamp(json, 'cancelledAt', cancelledAt);
    return json;
  }

  void _convertDateToTimestamp(
      Map<String, dynamic> json, String key, DateTime? date) {
    if (date != null) {
      json[key] = Timestamp.fromDate(date);
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isPending => status == 'pending_payment';
  bool get isPaid => status == 'paid';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isPacked => status == 'packed';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  bool get canCancel =>
      status == 'pending_payment' ||
      status == 'paid' ||
      status == 'confirmed';

  bool get canTrack =>
      status == 'shipped' || status == 'delivered';

  bool get canReorder => status == 'delivered' || status == 'cancelled';
}

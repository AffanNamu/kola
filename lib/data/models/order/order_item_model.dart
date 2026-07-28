import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String productId,
    required String productName,
    required String productImage,
    String? variantId,
    @Default('') String variantName,
    required double price,
    required int quantity,
    @Default('') String sku,
  }) = _OrderItemModel;

  const OrderItemModel._();

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  double get total => price * quantity;
}

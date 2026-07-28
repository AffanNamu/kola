import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/product/product_model.dart';

part 'product_state.freezed.dart';

@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded(List<ProductModel> products) = _Loaded;
  const factory ProductState.error(String message) = _Error;
}

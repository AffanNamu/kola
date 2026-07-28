import 'package:drift/drift.dart';

class CartItems extends Table {
  TextColumn get id => text()(); // productId|variantId
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get productImage => text().withDefault(const Constant(''))();
  TextColumn get variantId => text().nullable()();
  TextColumn get variantName => text().withDefault(const Constant(''))();
  TextColumn get sku => text().withDefault(const Constant(''))();

  RealColumn get price => real()(); // unit price
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get maxStock => integer().withDefault(const Constant(0))();

  DateTimeColumn get addedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

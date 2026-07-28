import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../tables/cart_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CartItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Cart queries
  Future<List<CartItem>> getCartItems() => select(cartItems).get();

  Stream<List<CartItem>> watchCartItems() => select(cartItems).watch();

  Future<int> cartCount() async {
    final rows = await getCartItems();
    return rows.fold(0, (sum, r) => sum + r.quantity);
  }

  Future<void> upsertCartItem(CartItemsCompanion item) async {
    await into(cartItems).insertOnConflictUpdate(item);
  }

  Future<void> updateQuantity(String id, int quantity) async {
    await (update(cartItems)..where((t) => t.id.equals(id))).write(
      CartItemsCompanion(quantity: Value(quantity)),
    );
  }

  Future<void> removeItem(String id) async {
    await (delete(cartItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearCart() async {
    await delete(cartItems).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kola.sqlite'));
    return NativeDatabase(file);
  });
}

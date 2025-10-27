import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'product.dart';

/// 🛒 Singleton Cart Class — digunakan untuk mengelola keranjang belanja
class Cart {
  // 🔹 Singleton Instance
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  // 🔹 List item dalam keranjang (realtime reactive)
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  /// Tambahkan produk ke keranjang.
  void add(Product product) {
    final list = List<CartItem>.from(items.value);

    final index = list.indexWhere((it) => it.product.id == product.id);

    if (index >= 0) {
      // Jika produk sudah ada, tambahkan jumlah
      list[index].qty++;
    } else {
      // Jika belum ada, tambahkan produk baru
      list.add(CartItem(product: product));
    }

    items.value = list;
  }

  /// Ubah jumlah produk di keranjang.
  void changeQty(Product product, int qty) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((it) => it.product.id == product.id);

    if (index >= 0) {
      if (qty <= 0) {
        // Hapus jika qty jadi 0 atau kurang
        list.removeAt(index);
      } else {
        list[index].qty = qty;
      }
      items.value = list;
    }
  }

  /// Hapus produk dari keranjang
  void remove(Product product) {
    final list = List<CartItem>.from(items.value)
      ..removeWhere((it) => it.product.id == product.id);
    items.value = list;
  }

  /// Jumlah total harga semua produk
  double get total {
    return items.value.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Kosongkan seluruh isi keranjang
  void clear() {
    items.value = [];
  }

  /// Jumlah total item (bukan harga)
  int get itemCount {
    return items.value.fold(0, (sum, item) => sum + item.qty);
  }

  /// Apakah keranjang kosong?
  bool get isEmpty => items.value.isEmpty;
}

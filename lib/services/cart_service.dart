import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class CartService {
  final supabase = Supabase.instance.client;

  /// ➕ Tambah ke cart
  Future<void> addToCart(Product p) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await supabase.from('cart').insert({
      'user_id': user.id,
      'product_id': p.id,
      'quantity': 1,
    });
  }

  /// 📥 Ambil semua cart milik user
  Future<List<Map<String, dynamic>>> fetchCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('cart')
        .select('id, quantity, product:product_id(id, name, price, image_url)')
        .eq('user_id', user.id)
        .order('created_at');

    return List<Map<String, dynamic>>.from(data);
  }

  /// 🗑️ Hapus dari cart (UUID)
  Future<void> removeFromCart(String cartId) async {
    await supabase.from('cart').delete().eq('id', cartId);
  }
}

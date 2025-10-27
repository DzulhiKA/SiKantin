import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<void> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int total,
    required String paymentMethod,
  }) async {
    // 1️⃣ Buat order baru
    final orderResponse = await supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'total': total,
          'payment_method': paymentMethod,
          'status': 'completed',
        })
        .select()
        .single();

    final orderId = orderResponse['id'] as String;

    // 2️⃣ Masukkan item-item ke order_items
    final orderItems = items.map((item) {
      return {
        'order_id': orderId,
        'product_id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'qty': item['qty'],
      };
    }).toList();

    await supabase.from('order_items').insert(orderItems);
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final int total;
  final String paymentMethod;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'items': items
          .map((i) => {
                'product_id': i.product.id,
                'name': i.product.name,
                'qty': i.qty,
                'price': i.product.price,
              })
          .toList(),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final orderService = OrderService();
  bool isLoading = false;

  int get total => widget.cartItems.fold<int>(
        0,
        (sum, item) =>
            sum + ((item['price'] as num) * (item['qty'] as num)).toInt(),
      );

  Future<void> _checkout() async {
    setState(() => isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    try {
      await orderService.createOrder(
        userId: user.id,
        items: widget.cartItems,
        total: total,
        paymentMethod: 'Cash',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil disimpan!')),
      );
      Navigator.pop(context); // kembali ke home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pesanan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: widget.cartItems
                    .map((item) => ListTile(
                          title: Text(item['name']),
                          subtitle: Text('Rp${item['price']} x ${item['qty']}'),
                          trailing: Text('Rp${item['price'] * item['qty']}'),
                        ))
                    .toList(),
              ),
            ),
            Text('Total: Rp$total',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _checkout,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Bayar Sekarang'),
            )
          ],
        ),
      ),
    );
  }
}

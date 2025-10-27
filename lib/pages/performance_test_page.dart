import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../controllers/product_http_controller.dart';
import '../controllers/product_dio_controller.dart';
import '../controllers/async_controller.dart';

class PerformanceTestPage extends StatelessWidget {
  const PerformanceTestPage({super.key});

  // 🔹 Tampilkan dialog JSON
  void _showJsonDialog(BuildContext context, dynamic data, String source) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📜 JSON Data ($source)'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonString,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // 🔹 Export JSON ke file
  Future<void> _exportJsonToFile(
      BuildContext context, dynamic data, String source) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/products_$source.json');
      await file.writeAsString(jsonString);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ File disimpan di:\n${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal mengekspor JSON: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final httpCtrl = Get.put(ProductHttpController());
    final dioCtrl = Get.put(ProductDioController());
    final asyncCtrl = Get.put(KantinController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔬 HTTP vs Dio Performance Test'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Uji performa pengambilan data produk menggunakan dua library berbeda.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // 🔹 Tombol Fetch Data
            ElevatedButton.icon(
              onPressed: httpCtrl.fetchProducts,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Fetch Data (HTTP)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: dioCtrl.fetchProducts,
              icon: const Icon(Icons.speed),
              label: const Text('Fetch Data (Dio)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 20),

            // 🔹 Informasi waktu respons
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⏱ HTTP Response Time: ${httpCtrl.responseTime} ms'),
                    Text('⚡ Dio Response Time: ${dioCtrl.responseTime} ms'),
                  ],
                )),
            const Divider(height: 30),

            // 🔹 Tombol untuk lihat & export JSON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showJsonDialog(
                          context, httpCtrl.productsRaw, 'HTTP'),
                      icon: const Icon(Icons.code),
                      label: const Text('Lihat JSON (HTTP)'),
                    ),
                    TextButton.icon(
                      onPressed: () => _exportJsonToFile(
                          context, httpCtrl.productsRaw, 'HTTP'),
                      icon: const Icon(Icons.download),
                      label: const Text('Export JSON (HTTP)'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showJsonDialog(context, dioCtrl.productsRaw, 'Dio'),
                      icon: const Icon(Icons.data_object),
                      label: const Text('Lihat JSON (Dio)'),
                    ),
                    TextButton.icon(
                      onPressed: () => _exportJsonToFile(
                          context, dioCtrl.productsRaw, 'Dio'),
                      icon: const Icon(Icons.download),
                      label: const Text('Export JSON (Dio)'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "📦 Data Produk (HTTP)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // 🔹 Daftar Produk
            Expanded(
              child: Obx(() {
                if (httpCtrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (httpCtrl.products.isEmpty) {
                  return const Text("Belum ada data (HTTP)");
                }
                return ListView.builder(
                  itemCount: httpCtrl.products.length,
                  itemBuilder: (context, index) {
                    final p = httpCtrl.products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.imageUrl,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.fastfood,
                                    color: Colors.orange),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Harga: Rp ${p.price.toStringAsFixed(0)}"),
                            if (p.category != null)
                              Text("Kategori: ${p.category!}"),
                            if (p.stock != null) Text("Stok: ${p.stock!} item"),
                            if (p.description.isNotEmpty)
                              Text(
                                "Deskripsi: ${p.description}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const Divider(height: 30),
            const Text(
              "🌦️ Eksperimen Async Handling",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // 🔹 Bagian eksperimen async handling
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: asyncCtrl.getRecommendationAsync,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Versi async/await'),
                    ),
                    ElevatedButton.icon(
                      onPressed: asyncCtrl.getRecommendationCallback,
                      icon: const Icon(Icons.link),
                      label: const Text('Versi callback chaining'),
                    ),
                    const SizedBox(height: 10),
                    if (asyncCtrl.isLoading.value)
                      const Center(child: CircularProgressIndicator()),
                    if (!asyncCtrl.isLoading.value &&
                        asyncCtrl.weather.isNotEmpty)
                      Text('🌤 Cuaca: ${asyncCtrl.weather.value}'),
                    if (!asyncCtrl.isLoading.value &&
                        asyncCtrl.recommendation.isNotEmpty)
                      Text('🎯 ${asyncCtrl.recommendation.value}'),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

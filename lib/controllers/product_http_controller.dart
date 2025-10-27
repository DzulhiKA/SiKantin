import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductHttpController extends GetxController {
  var products = <Product>[].obs; // Data produk hasil mapping ke model
  var productsRaw = [].obs; // Data mentah dari API (List<Map>)
  var isLoading = false.obs;
  var responseTime = 0.obs;
  var statusMessage = ''.obs; // Status info untuk debugging/logging

  /// Fungsi utama untuk mengambil data produk dari API menggunakan HTTP
  Future<void> fetchProducts() async {
    isLoading.value = true;
    statusMessage.value = '';
    final stopwatch = Stopwatch()..start();

    try {
      final url = Uri.parse('https://fakestoreapi.com/products');
      print('🌐 [HTTP] Sending GET request to: $url');

      final response = await http.get(url);

      stopwatch.stop();
      responseTime.value = stopwatch.elapsedMilliseconds;
      print('⏱️ [HTTP] Response time: ${responseTime.value} ms');

      if (response.statusCode == 200) {
        // Decode JSON ke List
        final List data = jsonDecode(response.body);

        // Simpan data mentah & olahan
        productsRaw.value = data;
        products.value = data.map((e) => Product.fromJson(e)).toList();

        statusMessage.value =
            '✅ [HTTP] Success: ${products.length} products loaded.';
        print(statusMessage.value);
      } else {
        statusMessage.value =
            '❌ [HTTP] Error ${response.statusCode}: ${response.reasonPhrase}';
        print(statusMessage.value);

        Get.snackbar(
          'Error ${response.statusCode}',
          'Gagal mengambil data produk dari server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE57373),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      stopwatch.stop(); 
      responseTime.value = stopwatch.elapsedMilliseconds;

      statusMessage.value = '⚠️ [HTTP] Exception: $e';
      print(statusMessage.value);

      Get.snackbar(
        'Koneksi Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFB74D),
        colorText: Colors.black,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fungsi opsional: bersihkan semua data produk
  void clearProducts() {
    products.clear();
    productsRaw.clear();
    statusMessage.value = '🧹 Data produk dihapus.';
    print(statusMessage.value);
  }
}

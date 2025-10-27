import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/product.dart';

class ProductDioController extends GetxController {
  var products = <Product>[].obs; // Data produk hasil mapping ke model
  var productsRaw = [].obs; // Data mentah dari API
  var isLoading = false.obs;
  var responseTime = 0.obs;
  var statusMessage = ''.obs; // Status info untuk logging/debugging

  late Dio dio;

  ProductDioController() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://fakestoreapi.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    // 🔹 Tambahkan logging interceptor untuk transparansi request/response
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('🧩 Dio Log → $obj'),
    ));

    print('✅ [Dio] Interceptor diaktifkan.');
  }

  /// Fungsi utama untuk fetch data produk via Dio
  Future<void> fetchProducts() async {
    isLoading.value = true;
    statusMessage.value = '';
    final stopwatch = Stopwatch()..start();

    try {
      print('🌐 [Dio] Sending GET request to /products');
      final response = await dio.get('/products');

      stopwatch.stop();
      responseTime.value = stopwatch.elapsedMilliseconds;
      print('⏱️ [Dio] Response time: ${responseTime.value} ms');

      if (response.statusCode == 200) {
        // Simpan data mentah & mapping ke model
        productsRaw.value = response.data;
        products.value =
            (response.data as List).map((e) => Product.fromJson(e)).toList();

        statusMessage.value =
            '✅ [Dio] Success: ${products.length} products loaded.';
        print(statusMessage.value);
      } else {
        statusMessage.value =
            '❌ [Dio] Error ${response.statusCode}: ${response.statusMessage}';
        print(statusMessage.value);

        Get.snackbar(
          'Error ${response.statusCode}',
          'Gagal mengambil data produk (Dio).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE57373),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      responseTime.value = stopwatch.elapsedMilliseconds;

      String message = 'Terjadi kesalahan koneksi.';
      if (e.type == DioExceptionType.connectionTimeout) {
        message = '⏰ Koneksi timeout. Server terlalu lama merespons.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = '⚠️ Server tidak merespons tepat waktu.';
      } else if (e.response != null) {
        message =
            '❌ Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
      } else if (e.message != null) {
        message = e.message!;
      }

      statusMessage.value = '[Dio] Exception: $message';
      print(statusMessage.value);

      Get.snackbar(
        'Dio Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFB74D),
        colorText: Colors.black,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      stopwatch.stop();
      responseTime.value = stopwatch.elapsedMilliseconds;

      statusMessage.value = '⚠️ [Dio] Unexpected error: $e';
      print(statusMessage.value);

      Get.snackbar(
        'Error',
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

  /// Bersihkan data hasil fetch
  void clearProducts() {
    products.clear();
    productsRaw.clear();
    statusMessage.value = '🧹 [Dio] Data produk dihapus.';
    print(statusMessage.value);
  }
}

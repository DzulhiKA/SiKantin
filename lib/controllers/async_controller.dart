import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class KantinController extends GetxController {
  var weather = ''.obs;
  var recommendation = ''.obs;
  var isLoading = false.obs;

  /// ✅ Versi async/await (lebih mudah dibaca)
  Future<void> getRecommendationAsync() async {
    try {
      isLoading.value = true;

      // 🌤️ 1. Ambil data cuaca
      final weatherRes = await http.get(
        Uri.parse('https://goweather.herokuapp.com/weather/Jakarta'),
      );

      final weatherData = json.decode(weatherRes.body);
      weather.value = weatherData['description'] ?? 'Unknown';

      // 🍱 2. Tentukan kategori makanan berdasarkan cuaca
      var category = _categoryFromWeather(weather.value);

      // 🍔 3. Ambil rekomendasi makanan dari TheMealDB
      var mealRes = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
      );

      var mealData = json.decode(mealRes.body);
      var mealList = mealData['meals'] as List?;

      // Jika kategori kosong, fallback ke kategori umum
      if (mealList == null) {
        category = 'Beef';
        mealRes = await http.get(
          Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
        );
        mealData = json.decode(mealRes.body);
        mealList = mealData['meals'] as List?;
      }

      if (mealList != null && mealList.isNotEmpty) {
        final mealName = mealList[0]['strMeal'];
        recommendation.value =
            'Cuaca: ${weather.value}\nRekomendasi makanan ($category): $mealName';
      } else {
        recommendation.value =
            'Tidak ada makanan ditemukan untuk kategori $category.';
      }
    } catch (e) {
      recommendation.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔗 Versi callback chaining
  void getRecommendationCallback() {
    isLoading.value = true;

    http
        .get(Uri.parse('https://goweather.herokuapp.com/weather/Jakarta'))
        .then((weatherRes) async {
      final weatherData = json.decode(weatherRes.body);
      weather.value = weatherData['description'] ?? 'Unknown';
      var category = _categoryFromWeather(weather.value);

      var mealRes = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
      );
      var mealData = json.decode(mealRes.body);
      var mealList = mealData['meals'] as List?;

      // Fallback kategori kalau null
      if (mealList == null) {
        category = 'Beef';
        mealRes = await http.get(
          Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
        );
        mealData = json.decode(mealRes.body);
        mealList = mealData['meals'] as List?;
      }

      if (mealList != null && mealList.isNotEmpty) {
        final mealName = mealList[0]['strMeal'];
        recommendation.value =
            'Rekomendasi makanan: $mealName (Cuaca: ${weather.value})';
      } else {
        recommendation.value = 'Tidak ada makanan ditemukan.';
      }
    }).catchError((e) {
      recommendation.value = 'Gagal: $e';
    }).whenComplete(() => isLoading.value = false);
  }

  /// 🧠 Tentukan kategori makanan berdasarkan cuaca
  String _categoryFromWeather(String weather) {
    final lower = weather.toLowerCase();
    if (lower.contains('rain')) return 'Soup'; // kadang kosong
    if (lower.contains('sun')) return 'Seafood';
    if (lower.contains('cloud')) return 'Dessert';
    if (lower.contains('clear')) return 'Chicken';
    return 'Beef';
  }
}

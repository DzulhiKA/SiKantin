import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final SharedPreferences prefs;

  ThemeController(this.prefs);

  // SIMPAN MODE GELAP → RxBool
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = prefs.getBool("darkMode") ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    prefs.setBool("darkMode", isDarkMode.value);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String keyIsDark = 'isDark';

  Future<void> saveIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsDark, isDark);
  }

  Future<bool> getIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsDark) ?? false;
  }
}

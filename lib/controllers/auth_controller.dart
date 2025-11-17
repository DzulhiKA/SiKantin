import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  final authBox = Hive.box('auth');

  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;
  RxString role = "".obs;

  @override
  void onInit() {
    super.onInit();

    // Load dari Hive
    isLoggedIn.value = authBox.get('isLoggedIn', defaultValue: false);
    role.value = authBox.get('role', defaultValue: "");

    // Redirect otomatis setelah frame build
    Future.delayed(Duration.zero, () {
      _redirect();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception("Email atau password salah");

      final data = await supabase
          .from("users")
          .select("role")
          .eq("id", user.id)
          .maybeSingle();

      final userRole = data?['role'] ?? "customer";

      // simpan ke Hive
      authBox.put("isLoggedIn", true);
      authBox.put("role", userRole);
      authBox.put("user_id", user.id);

      isLoggedIn.value = true;
      role.value = userRole;

      _redirect();
    } catch (e) {
      Get.snackbar("Login Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}

    // bersihkan hive
    authBox.put("isLoggedIn", false);
    authBox.put("role", "");
    authBox.put("user_id", "");

    isLoggedIn.value = false;
    role.value = "";

    Get.offAllNamed("/login");
  }

  void _redirect() {
    if (!isLoggedIn.value) {
      Get.offAllNamed("/login");
      return;
    }

    if (role.value == "admin") {
      Get.offAllNamed("/admin-home");
    } else {
      Get.offAllNamed("/customer-home");
    }
  }
}

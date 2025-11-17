import 'package:get/get.dart';
import '../services/hive_note_service.dart';
import '../models/note.dart';

class NoteLocalController extends GetxController {
  final HiveNoteService _service = HiveNoteService();

  var notes = <Note>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;

    // Micro delay supaya UI sempat re-render
    await Future.delayed(const Duration(milliseconds: 80));

    notes.assignAll(_service.getAll());

    loading.value = false;
  }

  Future<void> add(String title, String content) async {
    try {
      await _service.add(title, content);
      await load();
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan note: $e");
    }
  }

  /// 🔧 Ganti dari update() → edit()
  Future<void> edit(Note note, {String? title, String? content}) async {
    try {
      await _service.update(note, title: title, content: content);
      await load();
    } catch (e) {
      Get.snackbar("Error", "Gagal mengedit note: $e");
    }
  }

  Future<void> delete(Note note) async {
    try {
      await _service.delete(note);
      await load();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus note: $e");
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAll();
      await load();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus semua note: $e");
    }
  }
}

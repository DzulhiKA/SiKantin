import 'package:get/get.dart';
import '../services/cloud_note_service.dart';
import '../models/note.dart';

class NoteCloudController extends GetxController {
  final CloudNoteService _service = CloudNoteService();

  var notes = <Note>[].obs;
  var loading = false.obs;
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await _service.fetchNotes();
      notes.value = list;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> add(Note note) async {
    try {
      await _service.addNote(note);
      await fetch();
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// 🔥 FIX: Tidak bentrok dengan GetxController.update()
  Future<void> updateNote(String id, Map<String, dynamic> patch) async {
    try {
      // Buat patch aman:
      final safePatch = <String, dynamic>{};

      if (patch['title'] != null) safePatch['title'] = patch['title'];
      if (patch['content'] != null) safePatch['content'] = patch['content'];

      safePatch['updated_at'] = DateTime.now().toIso8601String();

      await _service.updateNote(id, safePatch);

      await fetch();
    } catch (e) {
      error.value = "Update gagal: $e";
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _service.deleteNote(id);
      await fetch();
    } catch (e) {
      error.value = e.toString();
    }
  }
}

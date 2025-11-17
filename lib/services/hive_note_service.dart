import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class HiveNoteService {
  static const String boxName = 'notes'; // FIX: harus sama dengan main.dart
  final Uuid _uuid = Uuid();

  Box<Note> get box => Hive.box<Note>(boxName);

  List<Note> getAll() {
    return box.values.toList();
  }

  Future<void> add(String title, String content) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
    );
    await box.add(note);
  }

  Future<void> update(Note note, {String? title, String? content}) async {
    note.title = title ?? note.title;
    note.content = content ?? note.content;
    note.updatedAt = DateTime.now();
    await note.save();
  }

  Future<void> delete(Note note) async {
    await note.delete();
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class CloudNoteService {
  final _client = Supabase.instance.client;
  final String table = 'notes';

  Future<List<Note>> fetchNotes() async {
    final data = await _client
        .from(table)
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((json) => Note.fromMap(json)).toList();
  }

  Future<void> addNote(Note note) async {
    await _client.from(table).insert(note.toMap());
  }

  Future<void> updateNote(String id, Map<String, dynamic> patch) async {
    await _client.from(table).update(patch).eq('id', id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_cloud_controller.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

class CloudNotePage extends StatelessWidget {
  CloudNotePage({Key? key}) : super(key: key);
  final NoteCloudController ctrl = Get.put(NoteCloudController());
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _uuid = Uuid();

  void _showAddDialog(BuildContext context) {
    _title.clear();
    _content.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tambah Note Cloud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Judul')),
            TextField(
                controller: _content,
                decoration: InputDecoration(labelText: 'Isi')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final note = Note(
                id: _uuid.v4(),
                title: _title.text,
                content: _content.text,
              );
              await ctrl.add(note);
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes Cloud (Supabase)'),
        actions: [
          IconButton(onPressed: () => ctrl.fetch(), icon: Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() {
        if (ctrl.loading.value)
          return Center(child: CircularProgressIndicator());
        if (ctrl.error.value != null)
          return Center(child: Text('Error: ${ctrl.error.value}'));
        if (ctrl.notes.isEmpty)
          return Center(child: Text('Belum ada note cloud'));
        return ListView.builder(
          itemCount: ctrl.notes.length,
          itemBuilder: (_, i) {
            final n = ctrl.notes[i];
            return ListTile(
              title: Text(n.title),
              subtitle: Text(n.content),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
                onSelected: (v) async {
                  if (v == 'delete') {
                    await ctrl.deleteNote(n.id);
                  }
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

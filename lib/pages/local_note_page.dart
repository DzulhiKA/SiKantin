import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_local_controller.dart';
import '../models/note.dart';

class LocalNotePage extends StatelessWidget {
  LocalNotePage({super.key});

  final NoteLocalController ctrl = Get.find<NoteLocalController>();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  /// Dialog untuk tambah catatan
  void _showAddDialog(BuildContext context) {
    _title.clear();
    _content.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan Lokal"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: _content,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Isi"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ctrl.add(_title.text, _content.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  /// Dialog untuk edit catatan
  void _showEditDialog(BuildContext context, Note note) {
    _title.text = note.title;
    _content.text = note.content;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: _content,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Isi"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ctrl.edit(
                note,
                title: _title.text,
                content: _content.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Lokal (Hive)"),
        actions: [
          IconButton(
            onPressed: () => ctrl.clearAll(),
            icon: const Icon(Icons.delete_forever),
            tooltip: "Hapus Semua",
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.notes.isEmpty) {
          return const Center(child: Text("Belum ada catatan"));
        }

        return ListView.builder(
          itemCount: ctrl.notes.length,
          itemBuilder: (_, i) {
            final note = ctrl.notes[i];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    const PopupMenuItem(value: 'delete', child: Text("Hapus")),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditDialog(context, note);
                    } else if (value == 'delete') {
                      await ctrl.delete(note);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ApiService.getNotes();
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addDialog() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await ApiService.addNote(
                title: titleCtrl.text.trim(),
                content: contentCtrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteNote(id);
      setState(() {
        _items.removeWhere((n) => n['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final n = _items[i];
                  return NoteCard(
                    title: n['title'] ?? '',
                    content: n['content'] ?? '',
                    onDelete: () => _delete(n['id']),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

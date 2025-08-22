import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameCtrl = TextEditingController();
  final tzCtrl = TextEditingController(text: 'Asia/Kolkata');
  bool _creating = false;
  bool _polling = false;
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    final p = StorageService.loadProfile();
    nameCtrl.text = p['name'] ?? 'me';
    tzCtrl.text = p['timezone'] ?? 'Asia/Kolkata';
    StorageService.loadThemeMode().then((v) => setState(() => _dark = v));
  }

  Future<void> _createUser() async {
    setState(() => _creating = true);
    try {
      await ApiService.createUser(externalId: nameCtrl.text.trim(), name: nameCtrl.text.trim(), timezone: tzCtrl.text.trim());
      await StorageService.saveProfile(name: nameCtrl.text.trim(), timezone: tzCtrl.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User configured ✅')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _creating = false);
    }
  }

  void _togglePolling() {
    if (_polling) {
      NotificationService.stopPolling();
    } else {
      NotificationService.startPolling();
    }
    setState(() => _polling = !_polling);
  }

  Future<void> _toggleTheme(bool v) async {
    await StorageService.saveThemeMode(v);
    setState(() => _dark = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Your Name / External ID')),
            const SizedBox(height: 8),
            TextField(controller: tzCtrl, decoration: const InputDecoration(labelText: 'Timezone')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _creating ? null : _createUser,
                icon: const Icon(Icons.save),
                label: Text(_creating ? 'Saving...' : 'Save Profile & Create User'),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _polling,
              onChanged: (_) => _togglePolling(),
              title: const Text('Enable Reminder Notifications (Polling)'),
              secondary: const Icon(Icons.notifications_active),
            ),
            SwitchListTile(
              value: _dark,
              onChanged: _toggleTheme,
              title: const Text('Dark Theme'),
              secondary: const Icon(Icons.dark_mode),
            ),
            const SizedBox(height: 12),
            const Text('Tip: Enable polling to get local notifications for due reminders.'),
          ],
        ),
      ),
    );
  }
}

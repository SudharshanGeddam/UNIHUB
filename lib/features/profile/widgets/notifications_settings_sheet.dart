import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsSheet extends StatefulWidget {
  const NotificationsSettingsSheet();
  @override
  State<NotificationsSettingsSheet> createState() =>
      NotificationsSettingsSheetState();
}

class NotificationsSettingsSheetState
    extends State<NotificationsSettingsSheet> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool studyReminders = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        pushEnabled = prefs.getBool('pushEnabled') ?? true;
        emailEnabled = prefs.getBool('emailEnabled') ?? false;
        studyReminders = prefs.getBool('studyReminders') ?? true;
      });
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Push Notifications',
                style: TextStyle(color: colorScheme.onSurface)),
            value: pushEnabled,
            onChanged: (val) {
              setState(() => pushEnabled = val);
              _saveSetting('pushEnabled', val);
            },
            activeThumbColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('Email Summaries',
                style: TextStyle(color: colorScheme.onSurface)),
            value: emailEnabled,
            onChanged: (val) {
              setState(() => emailEnabled = val);
              _saveSetting('emailEnabled', val);
            },
            activeThumbColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('Study Reminders',
                style: TextStyle(color: colorScheme.onSurface)),
            value: studyReminders,
            onChanged: (val) {
              setState(() => studyReminders = val);
              _saveSetting('studyReminders', val);
            },
            activeThumbColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

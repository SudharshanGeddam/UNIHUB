import 'package:flutter/material.dart';

class AccountSettingsSheet extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Function(String) onSave;

  const AccountSettingsSheet({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onSave,
  });

  @override
  State<AccountSettingsSheet> createState() => AccountSettingsSheetState();
}

class AccountSettingsSheetState extends State<AccountSettingsSheet> {
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Settings',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.userEmail,
            decoration: const InputDecoration(labelText: 'Email Address'),
            enabled: false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      try {
                        await widget.onSave(_nameController.text.trim());
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Settings saved successfully!')));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to save settings: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

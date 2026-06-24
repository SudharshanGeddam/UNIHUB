import 'package:flutter/material.dart';
import 'package:unihub/features/auth/services/auth_service.dart';

class PrivacySettingsSheet extends StatefulWidget {
  const PrivacySettingsSheet();
  @override
  State<PrivacySettingsSheet> createState() => PrivacySettingsSheetState();
}

class PrivacySettingsSheetState extends State<PrivacySettingsSheet> {
  bool analyticsEnabled = true;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _handleChangePassword() async {
    final email = _authService.currentUser?.email;
    if (email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No email associated with this account')));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent to $email')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send reset email: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This action is permanent and cannot be undone. All your data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _authService.currentUser?.delete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('requires-recent-login')
            ? 'Please sign out, sign back in, and try again (recent login required).'
            : 'Failed to delete account: $e';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          Text('Privacy & Security',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.password, color: colorScheme.primary),
            title: Text('Change Password',
                style: TextStyle(color: colorScheme.onSurface)),
            trailing: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
            onTap: _isLoading ? null : _handleChangePassword,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Share Analytics Data',
                style: TextStyle(color: colorScheme.onSurface)),
            subtitle: Text('Help us improve UniHub',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6))),
            value: analyticsEnabled,
            onChanged: (val) => setState(() => analyticsEnabled = val),
            activeThumbColor: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _handleDeleteAccount,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.error,
                      ),
                    )
                  : const Text('Delete Account',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

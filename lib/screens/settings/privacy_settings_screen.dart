import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: Consumer2<AuthProvider, SettingsProvider>(
        builder: (context, authProvider, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Data Management Section
              _buildPrivacySection(
                title: 'Data Management',
                children: [
                  _buildPrivacyTile(
                    icon: Icons.download,
                    title: 'Export My Data',
                    subtitle: 'Download a copy of your data (GDPR compliant)',
                    onTap: () => _exportUserData(authProvider, settingsProvider),
                    trailing: _isExporting 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                  _buildPrivacyTile(
                    icon: Icons.delete_forever,
                    title: 'Delete My Account',
                    subtitle: 'Permanently delete your account and all data',
                    onTap: () => _showDeleteAccountDialog(authProvider, settingsProvider),
                    trailing: _isDeleting 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right, color: Colors.red),
                    titleColor: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Privacy Controls Section
              _buildPrivacySection(
                title: 'Privacy Controls',
                children: [
                  _buildPrivacyTile(
                    icon: Icons.visibility_off,
                    title: 'Anonymous Reviews',
                    subtitle: 'Your reviews will be posted anonymously by default',
                    onTap: () => _showFeatureDialog('Anonymous Reviews'),
                  ),
                  _buildPrivacyTile(
                    icon: Icons.location_off,
                    title: 'Location Privacy',
                    subtitle: 'Control how your location is used and shared',
                    onTap: () => _showFeatureDialog('Location Privacy'),
                  ),
                  _buildPrivacyTile(
                    icon: Icons.analytics,
                    title: 'Analytics & Tracking',
                    subtitle: 'Manage data collection for app improvement',
                    onTap: () => _showFeatureDialog('Analytics & Tracking'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Legal & Compliance Section
              _buildPrivacySection(
                title: 'Legal & Compliance',
                children: [
                  _buildPrivacyTile(
                    icon: Icons.policy,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy and data practices',
                    onTap: () => _showPrivacyPolicy(),
                  ),
                  _buildPrivacyTile(
                    icon: Icons.gavel,
                    title: 'Terms of Service',
                    subtitle: 'View the terms and conditions',
                    onTap: () => _showTermsOfService(),
                  ),
                  _buildPrivacyTile(
                    icon: Icons.cookie,
                    title: 'Cookie Policy',
                    subtitle: 'Learn about our use of cookies and tracking',
                    onTap: () => _showCookiePolicy(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Data Rights Section
              _buildPrivacySection(
                title: 'Your Data Rights',
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    title: 'Right to Access',
                    subtitle: 'You can request access to your personal data at any time',
                  ),
                  _buildInfoTile(
                    icon: Icons.edit,
                    title: 'Right to Rectification',
                    subtitle: 'You can update or correct your personal information',
                  ),
                  _buildInfoTile(
                    icon: Icons.delete_outline,
                    title: 'Right to Erasure',
                    subtitle: 'You can request deletion of your personal data',
                  ),
                  _buildInfoTile(
                    icon: Icons.portable_wifi_off,
                    title: 'Right to Data Portability',
                    subtitle: 'You can export your data in a machine-readable format',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Contact Support
              Card(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Need Help?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you have questions about your privacy or data rights, contact our support team at privacy@streetbite.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _contactSupport(),
                        icon: const Icon(Icons.email),
                        label: const Text('Contact Support'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Future<void> _exportUserData(AuthProvider authProvider, SettingsProvider settingsProvider) async {
    if (authProvider.user == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final userData = await settingsProvider.exportUserData(authProvider.user!.uid);
      
      if (userData != null && mounted) {
        // Convert to JSON string
        final jsonString = const JsonEncoder.withIndent('  ').convert(userData);
        
        // Show export dialog
        _showExportDialog(jsonString);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showExportDialog(String jsonData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Export'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonData,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual file download/share
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export feature will be available in the full version'),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthProvider authProvider, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. Deleting your account will:'),
            SizedBox(height: 12),
            Text('• Remove all your personal data'),
            Text('• Delete your vendor profile (if applicable)'),
            Text('• Remove all your reviews and ratings'),
            Text('• Cancel any active subscriptions'),
            SizedBox(height: 12),
            Text(
              'Are you sure you want to permanently delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount(authProvider, settingsProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(AuthProvider authProvider, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text('Type "DELETE" to confirm account deletion:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount(authProvider, settingsProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(AuthProvider authProvider, SettingsProvider settingsProvider) async {
    if (authProvider.user == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await settingsProvider.deleteUserData(authProvider.user!.uid);
      
      if (success && mounted) {
        // Sign out user
        await authProvider.signOut();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'StreetBite Privacy Policy\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, such as when you create an account, update your profile, or contact us.\n\n'
            '2. How We Use Your Information\n'
            'We use the information we collect to provide, maintain, and improve our services.\n\n'
            '3. Information Sharing\n'
            'We do not sell, trade, or otherwise transfer your personal information to third parties.\n\n'
            '4. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '5. Your Rights\n'
            'You have the right to access, update, or delete your personal information.\n\n'
            'For the complete privacy policy, visit: www.streetbite.com/privacy',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'StreetBite Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using StreetBite, you agree to these terms.\n\n'
            '2. Use of Service\n'
            'You may use our service for lawful purposes only.\n\n'
            '3. User Accounts\n'
            'You are responsible for maintaining the security of your account.\n\n'
            '4. Content\n'
            'You retain ownership of content you post, but grant us license to use it.\n\n'
            '5. Prohibited Uses\n'
            'You may not use the service for illegal or unauthorized purposes.\n\n'
            'For the complete terms of service, visit: www.streetbite.com/terms',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCookiePolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cookie Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'StreetBite Cookie Policy\n\n'
            '1. What Are Cookies\n'
            'Cookies are small text files stored on your device.\n\n'
            '2. How We Use Cookies\n'
            'We use cookies to improve your experience and analyze usage.\n\n'
            '3. Types of Cookies\n'
            '- Essential cookies for basic functionality\n'
            '- Analytics cookies for usage statistics\n'
            '- Preference cookies for your settings\n\n'
            '4. Managing Cookies\n'
            'You can control cookies through your browser settings.\n\n'
            'For more information, visit: www.streetbite.com/cookies',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get help with privacy and data questions:'),
            SizedBox(height: 16),
            Text('📧 Email: privacy@streetbite.com'),
            SizedBox(height: 8),
            Text('📞 Phone: +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('🌐 Help Center: www.streetbite.com/help'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
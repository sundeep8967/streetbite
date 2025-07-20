import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user_model.dart';
import 'profile_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'app_preferences_screen.dart';
import 'vendor_hours_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      settingsProvider.loadUserSettings(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, SettingsProvider>(
        builder: (context, authProvider, settingsProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Text('Please log in to access settings'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Section
              _buildProfileSection(authProvider),
              
              const SizedBox(height: 24),
              
              // Settings Sections
              _buildSettingsSection(
                title: 'Account',
                children: [
                  _buildSettingsTile(
                    icon: Icons.person,
                    title: 'Profile Settings',
                    subtitle: 'Manage your personal information',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  if (authProvider.userProfile?.userType == UserType.vendor)
                    _buildSettingsTile(
                      icon: Icons.schedule,
                      title: 'Availability Hours',
                      subtitle: 'Set your stall operating hours',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VendorHoursScreen(),
                          ),
                        );
                      },
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                title: 'Preferences',
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.settings,
                    title: 'App Preferences',
                    subtitle: 'Theme, language, and display options',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppPreferencesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                title: 'Privacy & Security',
                children: [
                  _buildSettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Settings',
                    subtitle: 'Data management and privacy controls',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacySettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                title: 'Support',
                children: [
                  _buildSettingsTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      _showHelpDialog();
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(authProvider),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildProfileSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                authProvider.userProfile?.name.isNotEmpty == true
                    ? authProvider.userProfile!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userProfile?.name ?? 'User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.userProfile?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authProvider.userProfile?.userType == UserType.vendor 
                          ? 'Vendor' 
                          : 'Customer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('📧 Email: support@streetbite.com'),
            SizedBox(height: 8),
            Text('📞 Phone: +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('🌐 Website: www.streetbite.com/help'),
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'StreetBite',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.restaurant, size: 48),
      children: const [
        Text('Discover amazing street food vendors in your area.'),
        SizedBox(height: 8),
        Text('Built with Flutter and Firebase.'),
      ],
    );
  }
}
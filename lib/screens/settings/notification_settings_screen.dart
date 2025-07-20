import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/settings_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
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
        title: const Text('Notification Settings'),
      ),
      body: Consumer2<AuthProvider, SettingsProvider>(
        builder: (context, authProvider, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (settingsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${settingsProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSettings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = settingsProvider.userSettings?.notifications ?? 
              NotificationSettings.defaultSettings();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Master Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Enable Push Notifications'),
                        subtitle: const Text('Receive notifications on your device'),
                        value: notifications.pushNotifications,
                        onChanged: (value) {
                          _updateNotificationSetting('pushNotifications', value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content Notifications
              _buildNotificationSection(
                title: 'Content Notifications',
                children: [
                  _buildNotificationTile(
                    title: 'Vendor Status Updates',
                    subtitle: 'When vendors you follow open or close',
                    value: notifications.vendorStatusUpdates,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('vendorStatusUpdates', value),
                  ),
                  _buildNotificationTile(
                    title: 'Menu Updates',
                    subtitle: 'When vendors add new menu items',
                    value: notifications.menuUpdates,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('menuUpdates', value),
                  ),
                  _buildNotificationTile(
                    title: 'New Followers',
                    subtitle: 'When someone follows your vendor account',
                    value: notifications.newFollowers,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('newFollowers', value),
                  ),
                  _buildNotificationTile(
                    title: 'Ratings & Reviews',
                    subtitle: 'When you receive new ratings or reviews',
                    value: notifications.ratingsAndReviews,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('ratingsAndReviews', value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Marketing Notifications
              _buildNotificationSection(
                title: 'Marketing',
                children: [
                  _buildNotificationTile(
                    title: 'Promotions & Offers',
                    subtitle: 'Special deals and promotional content',
                    value: notifications.promotions,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('promotions', value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sound & Vibration
              _buildNotificationSection(
                title: 'Sound & Vibration',
                children: [
                  _buildNotificationTile(
                    title: 'Sound',
                    subtitle: 'Play sound for notifications',
                    value: notifications.soundEnabled,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('soundEnabled', value),
                  ),
                  _buildNotificationTile(
                    title: 'Vibration',
                    subtitle: 'Vibrate for notifications',
                    value: notifications.vibrationEnabled,
                    enabled: notifications.pushNotifications,
                    onChanged: (value) => _updateNotificationSetting('vibrationEnabled', value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quiet Hours
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiet Hours',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set times when you don\'t want to receive notifications',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'Start Time',
                              time: notifications.quietHoursStart,
                              onTimeChanged: (time) => _updateQuietHours(time, notifications.quietHoursEnd),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'End Time',
                              time: notifications.quietHoursEnd,
                              onTimeChanged: (time) => _updateQuietHours(notifications.quietHoursStart, time),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reset to Defaults
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _resetToDefaults(),
                  child: const Text('Reset to Defaults'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationSection({
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

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required ValueChanged<String> onTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(time, onTimeChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(String currentTime, ValueChanged<String> onTimeChanged) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeChanged(formattedTime);
    }
  }

  void _updateNotificationSetting(String setting, bool value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      settingsProvider.toggleNotification(authProvider.user!.uid, setting, value);
    }
  }

  void _updateQuietHours(String startTime, String endTime) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedNotifications = settingsProvider.userSettings!.notifications.copyWith(
        quietHoursStart: startTime,
        quietHoursEnd: endTime,
      );
      
      settingsProvider.updateNotificationSettings(authProvider.user!.uid, updatedNotifications);
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all notification settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              
              if (authProvider.user != null) {
                settingsProvider.updateNotificationSettings(
                  authProvider.user!.uid,
                  NotificationSettings.defaultSettings(),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
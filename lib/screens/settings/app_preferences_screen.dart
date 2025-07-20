import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/settings_model.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
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
        title: const Text('App Preferences'),
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

          final preferences = settingsProvider.userSettings?.preferences ?? 
              AppPreferences.defaultPreferences();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildPreferenceSection(
                title: 'Appearance',
                children: [
                  _buildDropdownTile(
                    title: 'Theme',
                    subtitle: 'Choose your preferred theme',
                    value: preferences.theme,
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      DropdownMenuItem(value: 'system', child: Text('System Default')),
                    ],
                    onChanged: (value) => _updateTheme(value!),
                  ),
                  _buildDropdownTile(
                    title: 'Language',
                    subtitle: 'Select your preferred language',
                    value: preferences.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                    ],
                    onChanged: (value) => _updateLanguage(value!),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location & Search Section
              _buildPreferenceSection(
                title: 'Location & Search',
                children: [
                  _buildSliderTile(
                    title: 'Search Radius',
                    subtitle: '${preferences.searchRadius.toStringAsFixed(1)} ${preferences.distanceUnit}',
                    value: preferences.searchRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    onChanged: (value) => _updateSearchRadius(value),
                  ),
                  _buildDropdownTile(
                    title: 'Distance Unit',
                    subtitle: 'Unit for displaying distances',
                    value: preferences.distanceUnit,
                    items: const [
                      DropdownMenuItem(value: 'km', child: Text('Kilometers (km)')),
                      DropdownMenuItem(value: 'miles', child: Text('Miles (mi)')),
                    ],
                    onChanged: (value) => _updateDistanceUnit(value!),
                  ),
                  _buildSwitchTile(
                    title: 'Show Online Vendors Only',
                    subtitle: 'Hide closed vendors from search results',
                    value: preferences.showOnlineVendorsOnly,
                    onChanged: (value) => _updateShowOnlineOnly(value),
                  ),
                  _buildSwitchTile(
                    title: 'Auto Location Update',
                    subtitle: 'Automatically update your location',
                    value: preferences.autoLocationUpdate,
                    onChanged: (value) => _updateAutoLocationUpdate(value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Map Settings Section
              _buildPreferenceSection(
                title: 'Map Settings',
                children: [
                  _buildDropdownTile(
                    title: 'Default Map Type',
                    subtitle: 'Preferred map display style',
                    value: preferences.defaultMapType,
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'satellite', child: Text('Satellite')),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                      DropdownMenuItem(value: 'terrain', child: Text('Terrain')),
                    ],
                    onChanged: (value) => _updateMapType(value!),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Privacy Section
              _buildPreferenceSection(
                title: 'Privacy',
                children: [
                  _buildSwitchTile(
                    title: 'Save Search History',
                    subtitle: 'Remember your recent searches',
                    value: preferences.saveSearchHistory,
                    onChanged: (value) => _updateSaveSearchHistory(value),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Reset Button
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

  Widget _buildPreferenceSection({
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

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _updateTheme(String theme) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.updateTheme(theme);
  }

  void _updateLanguage(String language) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.updateLanguage(language);
  }

  void _updateSearchRadius(double radius) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        searchRadius: radius,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _updateDistanceUnit(String unit) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        distanceUnit: unit,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _updateShowOnlineOnly(bool value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        showOnlineVendorsOnly: value,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _updateAutoLocationUpdate(bool value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        autoLocationUpdate: value,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _updateMapType(String mapType) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        defaultMapType: mapType,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _updateSaveSearchHistory(bool value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (authProvider.user != null && settingsProvider.userSettings != null) {
      final updatedPreferences = settingsProvider.userSettings!.preferences.copyWith(
        saveSearchHistory: value,
      );
      
      settingsProvider.updateAppPreferences(authProvider.user!.uid, updatedPreferences);
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all app preferences to their default values. Continue?'),
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
                settingsProvider.updateAppPreferences(
                  authProvider.user!.uid,
                  AppPreferences.defaultPreferences(),
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
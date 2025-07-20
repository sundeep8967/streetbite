import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/settings_model.dart';

class VendorHoursScreen extends StatefulWidget {
  const VendorHoursScreen({super.key});

  @override
  State<VendorHoursScreen> createState() => _VendorHoursScreenState();
}

class _VendorHoursScreenState extends State<VendorHoursScreen> {
  @override
  void initState() {
    super.initState();
    _loadVendorHours();
  }

  void _loadVendorHours() {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (vendorProvider.currentVendor != null) {
      settingsProvider.loadVendorAvailabilityHours(vendorProvider.currentVendor!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Hours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Consumer2<VendorProvider, SettingsProvider>(
        builder: (context, vendorProvider, settingsProvider, child) {
          if (vendorProvider.currentVendor == null) {
            return const Center(
              child: Text('Vendor profile not found'),
            );
          }

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
                    onPressed: _loadVendorHours,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final vendorHours = settingsProvider.vendorHours ?? 
              VendorAvailabilityHours.defaultSchedule(vendorProvider.currentVendor!.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Card
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
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Availability Hours',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set your stall operating hours for each day of the week. Customers will see when you\'re available and receive notifications when you open.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _applyToAllDays(vendorHours),
                              icon: const Icon(Icons.copy_all),
                              label: const Text('Copy Monday to All'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _setWeekendsClosed(vendorHours),
                              icon: const Icon(Icons.weekend),
                              label: const Text('Close Weekends'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Weekly Schedule
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Schedule',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...vendorHours.schedule.entries.map((entry) {
                        return _buildDaySchedule(
                          vendorProvider.currentVendor!.id,
                          entry.key,
                          entry.value,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveSchedule(vendorHours),
                  child: const Text('Save Schedule'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySchedule(String vendorId, String day, DaySchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: schedule.isOpen ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatDayName(day),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: schedule.isOpen
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTimeButton(
                              schedule.openTime,
                              (time) => _updateDayTime(vendorId, day, schedule, openTime: time),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('to'),
                          ),
                          Expanded(
                            child: _buildTimeButton(
                              schedule.closeTime,
                              (time) => _updateDayTime(vendorId, day, schedule, closeTime: time),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Closed',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              Switch(
                value: schedule.isOpen,
                onChanged: (value) => _toggleDayOpen(vendorId, day, schedule, value),
              ),
            ],
          ),
          
          // Break periods (if any)
          if (schedule.breaks.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...schedule.breaks.map((breakPeriod) => _buildBreakPeriod(breakPeriod)),
          ],
          
          // Add break button
          if (schedule.isOpen) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addBreakPeriod(vendorId, day, schedule),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Break'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeButton(String time, ValueChanged<String> onTimeChanged) {
    return InkWell(
      onTap: () => _selectTime(time, onTimeChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          time,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBreakPeriod(BreakPeriod breakPeriod) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.coffee, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            '${breakPeriod.startTime} - ${breakPeriod.endTime}',
            style: const TextStyle(fontSize: 12),
          ),
          if (breakPeriod.description != null) ...[
            const SizedBox(width: 8),
            Text(
              '(${breakPeriod.description})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Remove break period
            },
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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

  void _toggleDayOpen(String vendorId, String day, DaySchedule schedule, bool isOpen) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final updatedSchedule = DaySchedule(
      isOpen: isOpen,
      openTime: schedule.openTime,
      closeTime: schedule.closeTime,
      breaks: schedule.breaks,
    );
    
    settingsProvider.updateDaySchedule(vendorId, day, updatedSchedule);
  }

  void _updateDayTime(String vendorId, String day, DaySchedule schedule, {String? openTime, String? closeTime}) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final updatedSchedule = DaySchedule(
      isOpen: schedule.isOpen,
      openTime: openTime ?? schedule.openTime,
      closeTime: closeTime ?? schedule.closeTime,
      breaks: schedule.breaks,
    );
    
    settingsProvider.updateDaySchedule(vendorId, day, updatedSchedule);
  }

  void _addBreakPeriod(String vendorId, String day, DaySchedule schedule) {
    // TODO: Show dialog to add break period
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Break periods feature coming soon!')),
    );
  }

  void _applyToAllDays(VendorAvailabilityHours vendorHours) {
    final mondaySchedule = vendorHours.schedule['monday'];
    if (mondaySchedule == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to All Days'),
        content: Text('Apply Monday\'s schedule (${mondaySchedule.openTime} - ${mondaySchedule.closeTime}) to all days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              
              for (String day in ['tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']) {
                settingsProvider.updateDaySchedule(vendorHours.vendorId, day, mondaySchedule);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _setWeekendsClosed(VendorAvailabilityHours vendorHours) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Weekends'),
        content: const Text('Set Saturday and Sunday as closed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              
              for (String day in ['saturday', 'sunday']) {
                settingsProvider.updateDaySchedule(
                  vendorHours.vendorId, 
                  day, 
                  DaySchedule.closedDay(),
                );
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveSchedule(VendorAvailabilityHours vendorHours) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.saveVendorAvailabilityHours(vendorHours);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Availability Hours Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Set your stall operating hours for each day'),
            SizedBox(height: 8),
            Text('• Customers will see when you\'re available'),
            SizedBox(height: 8),
            Text('• Toggle days on/off as needed'),
            SizedBox(height: 8),
            Text('• Add break periods for lunch or rest'),
            SizedBox(height: 8),
            Text('• Use quick actions to set multiple days at once'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatDayName(String day) {
    return day[0].toUpperCase() + day.substring(1);
  }
}
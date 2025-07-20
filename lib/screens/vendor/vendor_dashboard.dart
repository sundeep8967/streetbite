import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor_model.dart';
import 'vendor_registration_screen.dart';
import 'menu_management_screen.dart';
import 'vendor_feedback_dashboard.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
  }

  void _loadVendorProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await vendorProvider.loadVendorProfile(authProvider.user!.uid);
      
      // If no vendor profile exists, redirect to registration
      if (vendorProvider.currentVendor == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorRegistrationScreen()),
        );
      }
    }
  }

  void _toggleStatus(bool isOpen) async {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final status = isOpen ? VendorStatus.open : VendorStatus.closed;
    
    final success = await vendorProvider.updateVendorStatus(status);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isOpen ? 'Stall is now Open!' : 'Stall is now Closed'),
          backgroundColor: isOpen ? Colors.green : Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vendorProvider.error ?? 'Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vendorProvider = Provider.of<VendorProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: vendorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${vendorProvider.currentVendor?.name ?? authProvider.userProfile?.name ?? 'Vendor'}!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (vendorProvider.currentVendor != null) ...[
                            Text(
                              '${vendorProvider.currentVendor!.cuisineType} - ${vendorProvider.currentVendor!.stallType.name.toUpperCase()} Stall',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vendorProvider.currentVendor!.followers.length} followers',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ] else
                            Text(
                              'Manage your stall and connect with customers',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status Toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stall Status',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendorProvider.currentVendor?.status == VendorStatus.open 
                                    ? 'Currently Open' 
                                    : 'Currently Closed',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: vendorProvider.currentVendor?.status == VendorStatus.open 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: vendorProvider.currentVendor?.status == VendorStatus.open,
                            onChanged: vendorProvider.isLoading ? null : _toggleStatus,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildActionCard(
                          icon: Icons.restaurant_menu,
                          title: 'Manage Menu',
                          subtitle: 'Add or edit items',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MenuManagementScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.location_on,
                          title: 'Update Location',
                          subtitle: 'Set your stall location',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Location update coming soon!')),
                            );
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.people,
                          title: 'Followers',
                          subtitle: 'View your followers',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Followers view coming soon!')),
                            );
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.star,
                          title: 'Reviews',
                          subtitle: 'Check customer feedback',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const VendorFeedbackDashboard(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
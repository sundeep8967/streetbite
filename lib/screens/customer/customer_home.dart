import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/vendor_model.dart';
import 'vendor_list_screen.dart';
import 'vendor_detail_screen.dart';
import 'map_view_screen.dart';
import '../settings/settings_screen.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';
import '../../widgets/animated/animated_bottom_nav.dart';
import '../../widgets/animated/animated_card.dart';
import '../../widgets/animated/animated_vendor_card.dart';
import '../../widgets/animated/animated_refresh_indicator.dart';
import '../../widgets/animated/page_transitions.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyVendors();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadNearbyVendors() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.getCurrentLocation();
  }

  Future<void> _refreshVendors() async {
    HapticFeedback.lightImpact();
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    await customerProvider.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(authProvider, customerProvider),
          _buildMapTab(),
          _buildFavoritesTab(customerProvider),
          _buildProfileTab(authProvider),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: AppAnimations.medium,
            curve: AppAnimations.iosEaseInOut,
          );
        },
        items: const [
          AnimatedBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          AnimatedBottomNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Map',
          ),
          AnimatedBottomNavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: 'Favorites',
          ),
          AnimatedBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(AuthProvider authProvider, CustomerProvider customerProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreetBite'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: AnimatedRefreshIndicator(
        onRefresh: _refreshVendors,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              AnimatedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authProvider.userProfile?.name ?? 'Food Lover'}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover amazing street food near you',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate()
               .fadeIn(duration: AppAnimations.medium)
               .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 20),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.restaurant,
                      title: 'Browse All',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VendorListScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.map,
                      title: 'Map View',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MapViewScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Open Now Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Now',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VendorListScreen()),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Open Vendors List
              if (customerProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (customerProvider.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load vendors',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadNearbyVendors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildOpenVendorsList(customerProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenVendorsList(CustomerProvider customerProvider) {
    final openVendors = customerProvider.nearbyVendors
        .where((vendor) => vendor.status == VendorStatus.open)
        .take(5)
        .toList();

    if (openVendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.store_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No vendors open nearby',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later or explore all vendors',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: openVendors.asMap().entries.map((entry) {
        final index = entry.key;
        final vendor = entry.value;
        return AnimatedVendorCard(
          vendor: vendor,
          onTap: () {
            NavigationHelper.pushIOS(
              context,
              VendorDetailScreen(vendor: vendor),
            );
          },
          margin: const EdgeInsets.only(bottom: 16),
        ).animate(delay: Duration(milliseconds: 100 * index))
         .fadeIn(duration: AppAnimations.medium)
         .slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }

  Widget _buildVendorCard(VendorModel vendor, CustomerProvider customerProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final distance = customerProvider.getDistanceToVendor(vendor);
    final isFollowing = authProvider.user != null && 
                       vendor.followers.contains(authProvider.user!.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VendorDetailScreen(vendor: vendor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vendor Image Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
              
              const SizedBox(width: 16),
              
              // Vendor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OPEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.cuisineType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          vendor.rating > 0 ? vendor.rating.toStringAsFixed(1) : 'New',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, color: Colors.grey[600], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite Button
              IconButton(
                onPressed: () async {
                  if (authProvider.user != null) {
                    await customerProvider.toggleFavoriteVendor(
                      vendor.id,
                      authProvider.user!.uid,
                    );
                  }
                },
                icon: Icon(
                  isFollowing ? Icons.favorite : Icons.favorite_border,
                  color: isFollowing ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return const MapViewScreen();
  }

  Widget _buildFavoritesTab(CustomerProvider customerProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      customerProvider.loadFavoriteVendors(authProvider.user!.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: customerProvider.favoriteVendors.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favorites yet'),
                  Text('Follow vendors to see them here', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customerProvider.favoriteVendors.length,
              itemBuilder: (context, index) {
                final vendor = customerProvider.favoriteVendors[index];
                return _buildVendorCard(vendor, customerProvider);
              },
            ),
    );
  }

  Widget _buildProfileTab(AuthProvider authProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.userProfile?.name ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authProvider.userProfile?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => authProvider.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
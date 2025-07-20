import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vendor_model.dart';
import '../../constants/app_constants.dart';
import 'vendor_detail_screen.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadVendors() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.getCurrentLocation();
  }

  void _showFilterBottomSheet() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Vendors',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Cuisine Filter
                Text(
                  'Cuisine Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedCuisineFilter == null,
                      onSelected: (_) => provider.filterByCuisine(null),
                    ),
                    ...AppConstants.cuisineTypes.map((cuisine) {
                      return FilterChip(
                        label: Text(cuisine),
                        selected: provider.selectedCuisineFilter == cuisine,
                        onSelected: (_) => provider.filterByCuisine(cuisine),
                      );
                    }).toList(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Status Filter
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedStatusFilter == null,
                      onSelected: (_) => provider.filterByStatus(null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Open'),
                      selected: provider.selectedStatusFilter == VendorStatus.open,
                      onSelected: (_) => provider.filterByStatus(VendorStatus.open),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Closed'),
                      selected: provider.selectedStatusFilter == VendorStatus.closed,
                      onSelected: (_) => provider.filterByStatus(VendorStatus.closed),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortOptions() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Distance'),
              onTap: () {
                customerProvider.sortVendorsByDistance();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rating'),
              onTap: () {
                customerProvider.sortVendorsByRating();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Vendors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding nearby vendors...'),
                ],
              ),
            );
          }

          if (customerProvider.error != null) {
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
                    'Error: ${customerProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVendors,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final vendors = customerProvider.filteredVendors;

          if (vendors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No vendors found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or search in a different area',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      customerProvider.clearFilters();
                      _loadVendors();
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vendors, cuisine, location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              customerProvider.searchVendors('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: customerProvider.searchVendors,
                ),
              ),

              // Active Filters
              if (customerProvider.selectedCuisineFilter != null ||
                  customerProvider.selectedStatusFilter != null ||
                  customerProvider.searchQuery.isNotEmpty)
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (customerProvider.searchQuery.isNotEmpty)
                        Chip(
                          label: Text('Search: ${customerProvider.searchQuery}'),
                          onDeleted: () {
                            _searchController.clear();
                            customerProvider.searchVendors('');
                          },
                        ),
                      if (customerProvider.selectedCuisineFilter != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(customerProvider.selectedCuisineFilter!),
                          onDeleted: () => customerProvider.filterByCuisine(null),
                        ),
                      ],
                      if (customerProvider.selectedStatusFilter != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(customerProvider.selectedStatusFilter!.name.toUpperCase()),
                          onDeleted: () => customerProvider.filterByStatus(null),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Vendor List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: customerProvider.refreshVendors,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return _buildVendorCard(vendor, customerProvider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.cuisineType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vendor.status == VendorStatus.open
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vendor.status == VendorStatus.open ? 'OPEN' : 'CLOSED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                ],
              ),

              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    vendor.rating > 0 ? vendor.rating.toStringAsFixed(1) : 'New',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text('${vendor.followers.length} followers'),
                  if (distance != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text('${distance.toStringAsFixed(1)} km'),
                  ],
                ],
              ),

              if (vendor.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        vendor.address!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
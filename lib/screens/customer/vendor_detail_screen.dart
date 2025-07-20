import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendor_model.dart';
import '../../providers/customer_provider.dart';

class VendorDetailScreen extends StatelessWidget {
  final VendorModel vendor;

  const VendorDetailScreen({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(vendor.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: vendor.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        vendor.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Vendor Name and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    vendor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: vendor.status == VendorStatus.open ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vendor.status == VendorStatus.open ? 'OPEN' : 'CLOSED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Cuisine Type
            Text(
              vendor.cuisineType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.orange,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  vendor.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${vendor.followers.length} followers)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Address
            if (vendor.address != null) ...[
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vendor.address!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
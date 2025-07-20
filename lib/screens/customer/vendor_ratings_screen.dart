import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vendor_model.dart';
import '../../models/rating_model.dart';
import 'add_rating_screen.dart';

class VendorRatingsScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorRatingsScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorRatingsScreen> createState() => _VendorRatingsScreenState();
}

class _VendorRatingsScreenState extends State<VendorRatingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  void _loadRatings() {
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ratingProvider.loadVendorRatings(widget.vendor.id);
    
    if (authProvider.user != null) {
      ratingProvider.loadCurrentUserRating(authProvider.user!.uid, widget.vendor.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user != null) {
                return IconButton(
                  icon: const Icon(Icons.rate_review),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddRatingScreen(vendor: widget.vendor),
                      ),
                    );
                    
                    if (result == true) {
                      _loadRatings(); // Refresh ratings after adding/updating
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          if (ratingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ratingProvider.error != null) {
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
                    'Error: ${ratingProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRatings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadRatings(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Vendor Info Card
                _buildVendorInfoCard(),
                
                const SizedBox(height: 16),
                
                // Rating Statistics
                if (ratingProvider.vendorStats != null)
                  _buildRatingStats(ratingProvider.vendorStats!),
                
                const SizedBox(height: 16),
                
                // Current User Rating (if exists)
                if (ratingProvider.currentUserRating != null) ...[
                  _buildCurrentUserRating(ratingProvider.currentUserRating!),
                  const SizedBox(height: 16),
                ],
                
                // Reviews List
                _buildReviewsList(ratingProvider.vendorRatings),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user != null) {
            return FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddRatingScreen(vendor: widget.vendor),
                  ),
                );
                
                if (result == true) {
                  _loadRatings();
                }
              },
              child: const Icon(Icons.rate_review),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVendorInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: widget.vendor.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.vendor.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.restaurant, size: 30);
                        },
                      ),
                    )
                  : const Icon(Icons.restaurant, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vendor.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vendor.cuisineType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < widget.vendor.rating 
                              ? Icons.star 
                              : Icons.star_border,
                          size: 20,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        widget.vendor.rating > 0 
                            ? '${widget.vendor.rating.toStringAsFixed(1)} (${widget.vendor.totalRatings})'
                            : 'No ratings yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStats(VendorRatingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Overall rating
            Row(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const Spacer(),
                Text(
                  '${stats.totalRatings} reviews',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Rating distribution
            ...List.generate(5, (index) {
              int stars = 5 - index;
              int count = stats.ratingDistribution[stars] ?? 0;
              double percentage = stats.totalRatings > 0 
                  ? (count / stats.totalRatings) * 100 
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('$stars'),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUserRating(RatingModel rating) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Rating',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddRatingScreen(vendor: widget.vendor),
                      ),
                    );
                    
                    if (result == true) {
                      _loadRatings();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  rating.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                rating.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Posted on ${_formatDate(rating.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<RatingModel> ratings) {
    final otherRatings = ratings.where((rating) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.user == null || rating.customerId != authProvider.user!.uid;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews (${otherRatings.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (otherRatings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to review this vendor!',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...otherRatings.map((rating) => _buildReviewCard(rating)),
      ],
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    rating.customerName.isNotEmpty 
                        ? rating.customerName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.customerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            rating.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(rating.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                rating.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
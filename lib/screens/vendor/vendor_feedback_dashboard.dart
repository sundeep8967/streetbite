import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/rating_model.dart';

class VendorFeedbackDashboard extends StatefulWidget {
  const VendorFeedbackDashboard({super.key});

  @override
  State<VendorFeedbackDashboard> createState() => _VendorFeedbackDashboardState();
}

class _VendorFeedbackDashboardState extends State<VendorFeedbackDashboard> {
  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  void _loadFeedback() {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    
    if (vendorProvider.currentVendor != null) {
      ratingProvider.loadVendorRatings(vendorProvider.currentVendor!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedback,
          ),
        ],
      ),
      body: Consumer2<VendorProvider, RatingProvider>(
        builder: (context, vendorProvider, ratingProvider, child) {
          if (vendorProvider.currentVendor == null) {
            return const Center(
              child: Text('Vendor profile not found'),
            );
          }

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
                    onPressed: _loadFeedback,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadFeedback(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overall Statistics
                if (ratingProvider.vendorStats != null)
                  _buildOverallStats(ratingProvider.vendorStats!),
                
                const SizedBox(height: 16),
                
                // Rating Distribution
                if (ratingProvider.vendorStats != null)
                  _buildRatingDistribution(ratingProvider.vendorStats!),
                
                const SizedBox(height: 16),
                
                // Recent Reviews
                _buildRecentReviews(ratingProvider.vendorRatings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(VendorRatingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Rating',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Average Rating
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        stats.averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(stats.averageRating),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < stats.averageRating 
                                ? Icons.star 
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average Rating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Total Reviews
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        stats.totalRatings.toString(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Reviews',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rating Trend (placeholder)
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trending',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(VendorRatingStats stats) {
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
            
            ...List.generate(5, (index) {
              int stars = 5 - index;
              int count = stats.ratingDistribution[stars] ?? 0;
              double percentage = stats.totalRatings > 0 
                  ? (count / stats.totalRatings) * 100 
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$stars',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRatingColor(stars.toDouble()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$count (${percentage.toStringAsFixed(1)}%)',
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

  Widget _buildRecentReviews(List<RatingModel> ratings) {
    final reviewsWithComments = ratings
        .where((rating) => rating.comment != null && rating.comment!.isNotEmpty)
        .take(10)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Reviews',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${reviewsWithComments.length} reviews',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (reviewsWithComments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
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
                        'Customer reviews will appear here',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...reviewsWithComments.map((rating) => _buildReviewCard(rating)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  rating.customerName.isNotEmpty 
                      ? rating.customerName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.customerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating.rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 4),
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
            const SizedBox(height: 8),
            Text(
              rating.comment!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
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
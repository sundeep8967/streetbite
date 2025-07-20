import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vendor_model.dart';

class AddRatingScreen extends StatefulWidget {
  final VendorModel vendor;

  const AddRatingScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<AddRatingScreen> createState() => _AddRatingScreenState();
}

class _AddRatingScreenState extends State<AddRatingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  double _rating = 5.0;
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadExistingRating() {
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      ratingProvider.loadCurrentUserRating(authProvider.user!.uid, widget.vendor.id);
      
      // Pre-fill form if user has already rated
      if (ratingProvider.currentUserRating != null) {
        final existingRating = ratingProvider.currentUserRating!;
        setState(() {
          _rating = existingRating.rating;
          _commentController.text = existingRating.comment ?? '';
          _isAnonymous = existingRating.isAnonymous;
        });
      }
    }
  }

  Future<void> _submitRating() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ratingProvider.addOrUpdateRating(
        vendorId: widget.vendor.id,
        customerId: authProvider.user!.uid,
        customerName: authProvider.userProfile?.name ?? 'Anonymous User',
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ratingProvider.currentUserRating?.createdAt == ratingProvider.currentUserRating?.updatedAt
                  ? 'Rating submitted successfully!'
                  : 'Rating updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ratingProvider.error ?? 'Failed to submit rating'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = (index + 1).toDouble();
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: Colors.amber,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(_rating),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: _getRatingColor(_rating),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this vendor';
    }
  }

  Color _getRatingColor(double rating) {
    switch (rating.toInt()) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<RatingProvider>(context);
    final isEditing = ratingProvider.currentUserRating != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rating' : 'Rate Vendor'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Rating'),
                    content: const Text('Are you sure you want to delete your rating?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await ratingProvider.deleteRating(
                    ratingProvider.currentUserRating!.id,
                    widget.vendor.id,
                  );

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rating deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ratingProvider.error ?? 'Failed to delete rating'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Vendor Info Card
            Card(
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                widget.vendor.rating > 0 
                                    ? '${widget.vendor.rating.toStringAsFixed(1)} (${widget.vendor.totalRatings})'
                                    : 'No ratings yet',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Star Rating Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStarRating(),
              ),
            ),

            const SizedBox(height: 16),

            // Comment Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Review (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience with this vendor...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Post anonymously'),
                      subtitle: const Text('Your name will be hidden from other users'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Rating' : 'Submit Rating'),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
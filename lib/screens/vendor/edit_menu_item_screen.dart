import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/menu_provider.dart';
import '../../models/menu_item_model.dart';
import '../../constants/app_constants.dart';

class EditMenuItemScreen extends StatefulWidget {
  final MenuItemModel menuItem;

  const EditMenuItemScreen({
    super.key,
    required this.menuItem,
  });

  @override
  State<EditMenuItemScreen> createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  late String _selectedCategory;
  late bool _isAvailable;
  File? _selectedImage;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem.name);
    _descriptionController = TextEditingController(text: widget.menuItem.description ?? '');
    _priceController = TextEditingController(text: widget.menuItem.price.toString());
    _selectedCategory = widget.menuItem.category;
    _isAvailable = widget.menuItem.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _imageChanged = true;
    });
  }

  Future<void> _updateMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedItem = widget.menuItem.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        isAvailable: _isAvailable,
        updatedAt: DateTime.now(),
      );

      final success = await menuProvider.updateMenuItem(
        updatedItem,
        imageFile: _imageChanged ? _selectedImage : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu item updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update menu item'),
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

  Widget _buildImageSection() {
    // Show selected new image
    if (_selectedImage != null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    // Show existing image if no new image selected and not removed
    if (!_imageChanged && widget.menuItem.imageUrl != null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.menuItem.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant, size: 48, color: Colors.grey),
              );
            },
          ),
        ),
      );
    }
    
    // Show placeholder
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
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
        title: const Text('Edit Menu Item'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _updateMenuItem,
              child: const Text('Update'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Image',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildImageSection(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit),
                            label: Text(_selectedImage != null || (!_imageChanged && widget.menuItem.imageUrl != null)
                                ? 'Change Image'
                                : 'Add Image'),
                          ),
                        ),
                        if (_selectedImage != null || (!_imageChanged && widget.menuItem.imageUrl != null)) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _removeImage,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Basic Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Item Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'e.g., Chicken Biryani',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter item name';
                        }
                        if (value.trim().length < 2) {
                          return 'Item name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Describe your dish...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 200,
                    ),

                    const SizedBox(height: 16),

                    // Price and Category Row
                    Row(
                      children: [
                        // Price
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price *',
                              hintText: '0.00',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter price';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null) {
                                return 'Please enter valid price';
                              }
                              if (price <= 0) {
                                return 'Price must be greater than 0';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Category
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              border: OutlineInputBorder(),
                            ),
                            items: AppConstants.menuCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Availability Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Available for order'),
                      subtitle: Text(
                        _isAvailable 
                            ? 'Customers can order this item'
                            : 'This item will be hidden from customers',
                      ),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateMenuItem,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Menu Item'),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
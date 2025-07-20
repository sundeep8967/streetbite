import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

import '../../providers/vendor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vendor_model.dart';
import '../../constants/app_constants.dart';
import 'vendor_dashboard.dart';
import 'location_picker_screen.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedCuisine = AppConstants.cuisineTypes.first;
  StallType _selectedStallType = StallType.fixed;
  GeoPoint? _selectedLocation;
  File? _selectedImage;
  bool _isLoading = false;

  final Map<String, String> _availabilityHours = {
    'monday': '9:00 AM - 9:00 PM',
    'tuesday': '9:00 AM - 9:00 PM',
    'wednesday': '9:00 AM - 9:00 PM',
    'thursday': '9:00 AM - 9:00 PM',
    'friday': '9:00 AM - 9:00 PM',
    'saturday': '9:00 AM - 9:00 PM',
    'sunday': '9:00 AM - 9:00 PM',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
        
        setState(() {
          _selectedLocation = GeoPoint(position.latitude, position.longitude);
          _addressController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const LocationPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result['location'] as GeoPoint;
        _addressController.text = result['address'] as String;
      });
    }
  }

  Future<void> _registerVendor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your location')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

      // TODO: Upload image to Firebase Storage when Firebase is configured
      String? imageUrl;
      if (_selectedImage != null) {
        // For now, we'll just use a placeholder
        imageUrl = 'placeholder_image_url';
      }

      final success = await vendorProvider.createVendorProfile(
        userId: authProvider.user!.uid,
        name: _nameController.text.trim(),
        cuisineType: _selectedCuisine,
        stallType: _selectedStallType,
        location: _selectedLocation!,
        address: _addressController.text.trim(),
        imageUrl: imageUrl,
        availabilityHours: _availabilityHours,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor profile created successfully!')),
        );
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorDashboard()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vendorProvider.error ?? 'Registration failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to add profile photo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Vendor Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor/Stall Name',
                  hintText: 'Enter your business name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your vendor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Cuisine Type
              DropdownButtonFormField<String>(
                value: _selectedCuisine,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                items: AppConstants.cuisineTypes.map((cuisine) {
                  return DropdownMenuItem(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCuisine = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Stall Type
              const Text(
                'Stall Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<StallType>(
                      title: const Text('Fixed'),
                      subtitle: const Text('Permanent location'),
                      value: StallType.fixed,
                      groupValue: _selectedStallType,
                      onChanged: (value) {
                        setState(() {
                          _selectedStallType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<StallType>(
                      title: const Text('Mobile'),
                      subtitle: const Text('Moving location'),
                      value: StallType.mobile,
                      groupValue: _selectedStallType,
                      onChanged: (value) {
                        setState(() {
                          _selectedStallType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location Section
              const Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your location address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Current Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickLocation,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (_selectedLocation != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Location selected',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _registerVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Register as Vendor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
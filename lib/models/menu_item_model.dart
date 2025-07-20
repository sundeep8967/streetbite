class MenuItemModel {
  final String id;
  final String vendorId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemModel({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
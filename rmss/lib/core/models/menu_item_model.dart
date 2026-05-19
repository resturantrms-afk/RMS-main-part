import 'package:equatable/equatable.dart';

enum MenuItemStatus { available, unavailable }

class MenuItemModel extends Equatable {
  final String id; // Firebase Document ID
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> category;
  final MenuItemStatus status; // e.g., 'Available', 'Unavailable'

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.status,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MenuItemModel(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: List<String>.from(json['category'] ?? []),

      status: MenuItemStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'available'),
        orElse: () => MenuItemStatus.available,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'status': status.name,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    category,
    status,
  ];
}

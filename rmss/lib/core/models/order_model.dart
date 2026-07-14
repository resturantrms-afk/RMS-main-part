import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, preparing, ready, served, paid, cancelled }

class OrderModel extends Equatable {
  final String id;
  final String tableId;
  final int tableNumber;
  final Map<String, dynamic> createdBy;
  final String source; // "Web App" or "POS"
  final double totalPrice;
  final OrderStatus status;
  final Timestamp createdAt;

  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.createdBy,
    required this.source,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String documentId) {
    return OrderModel(
      id: documentId,
      tableId: json['tableId'] ?? '',
      tableNumber: json['tableNumber'] ?? 0,
      createdBy: json['createdBy'] as Map<String, dynamic>? ?? {},
      source: json['source'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: json['createdAt'] ?? Timestamp.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'createdBy': createdBy,
      'source': source,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? tableId,
    int? tableNumber,
    Map<String, dynamic>? createdBy,
    String? source,
    double? totalPrice,
    OrderStatus? status,
    Timestamp? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      createdBy: createdBy ?? this.createdBy,
      source: source ?? this.source,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tableId,
        tableNumber,
        createdBy,
        source,
        totalPrice,
        status,
        createdAt,
        items,
      ];
}

class OrderItemModel extends Equatable {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String notes;
  final String imageUrl;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.notes,
    this.imageUrl = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menuItemId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      notes: json['notes'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        price,
        quantity,
        notes,
        imageUrl,
      ];
}
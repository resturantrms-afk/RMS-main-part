import 'package:equatable/equatable.dart';

class MenuProfileModel extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final List<String> menuItemIds;

  const MenuProfileModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.menuItemIds,
  });

  MenuProfileModel copyWith({
    String? id,
    String? name,
    bool? isActive,
    List<String>? menuItemIds,
  }) {
    return MenuProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      menuItemIds: menuItemIds ?? this.menuItemIds,
    );
  }

  factory MenuProfileModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MenuProfileModel(
      id: documentId,
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? false,
      menuItemIds: List<String>.from(json['menuItemIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isActive': isActive,
      'menuItemIds': menuItemIds,
    };
  }

  @override
  List<Object?> get props => [id, name, isActive, menuItemIds];
}

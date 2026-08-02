import 'package:flutter/material.dart';

enum AppNotificationType { order, table, system }

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AppNotificationType type;
  final String? relatedId;
  final bool playSound;
  final double volume;
  bool isRead;
  final List<String> targetRoles;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.relatedId,
    this.playSound = true,
    this.volume = 75.0,
    this.isRead = false,
    this.targetRoles = const [],
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    AppNotificationType? type,
    String? relatedId,
    bool? playSound,
    double? volume,
    bool? isRead,
    List<String>? targetRoles,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      playSound: playSound ?? this.playSound,
      volume: volume ?? this.volume,
      isRead: isRead ?? this.isRead,
      targetRoles: targetRoles ?? this.targetRoles,
    );
  }

  IconData get icon {
    switch (type) {
      case AppNotificationType.order:
        return Icons.restaurant_menu;
      case AppNotificationType.table:
        return Icons.table_restaurant;
      case AppNotificationType.system:
        return Icons.settings;
    }
  }

  String timeAgo() {
    Duration duration = DateTime.now().difference(timestamp);
    if (duration.inDays > 0) {
      return "${duration.inDays} days ago";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} hrs ago";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} mins ago";
    } else {
      return "Just now";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'relatedId': relatedId,
      'playSound': playSound,
      'volume': volume,
      'isRead': isRead,
      'targetRoles': targetRoles,
    };
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AppNotificationModel(
      id: documentId,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      type: AppNotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AppNotificationType.system),
      relatedId: json['relatedId'],
      playSound: json['playSound'] ?? true,
      volume: (json['volume'] ?? 75.0).toDouble(),
      isRead: json['isRead'] ?? false,
      targetRoles: List<String>.from(json['targetRoles'] ?? []),
    );
  }
}

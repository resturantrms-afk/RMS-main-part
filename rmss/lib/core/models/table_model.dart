import 'package:equatable/equatable.dart';

enum TableStatus { available, occupied, needsCleaning }

class TableModel extends Equatable {
  final String id;
  final int tableNumber;
  final TableStatus status;
  final bool needsHelp;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
    this.needsHelp = false,
  });

  factory TableModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TableModel(
      id: documentId,
      tableNumber: json['tableNumber'] ?? 0,
      status: TableStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'available'),
        orElse: () => TableStatus.available,
      ),
      needsHelp: json['needsHelp'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status.name,
      'needsHelp': needsHelp,
    };
  }

  TableModel copyWith({
    String? id,
    int? tableNumber,
    TableStatus? status,
    bool? needsHelp,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      needsHelp: needsHelp ?? this.needsHelp,
    );
  }

  @override
  List<Object?> get props => [id, tableNumber, status, needsHelp];
}

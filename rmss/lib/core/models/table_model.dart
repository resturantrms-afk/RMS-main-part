import 'package:equatable/equatable.dart';

enum TableStatus { available, occupied, needsCleaning }

class TableModel extends Equatable {
  final String id;
  final int tableNumber;
  final TableStatus status;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TableModel(
      id: documentId,
      tableNumber: json['tableNumber'] ?? 0,
      status: TableStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'available'),
        orElse: () => TableStatus.available,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'tableNumber': tableNumber, 'status': status.name};
  }

  @override
  List<Object?> get props => [id, tableNumber, status];
}

import 'package:equatable/equatable.dart';
import 'package:rmss/features/admin/models/reports/association_report.dart';
import 'package:rmss/features/admin/models/reports/category_performance_report.dart';
import 'package:rmss/features/admin/models/reports/item_importance_report.dart';
import 'package:rmss/features/admin/models/reports/payment_processing_ledger.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ItemImportanceReport> itemImportanceReports;
  final List<PaymentProcessingLedger> paymentLedgers;
  final AssociationAlgorithmReport associationReport;
  final List<CategoryPerformanceReport> categoryPerformance;

  const ReportsLoaded({
    required this.itemImportanceReports,
    required this.paymentLedgers,
    required this.associationReport,
    required this.categoryPerformance,
  });

  @override
  List<Object?> get props => [
        itemImportanceReports,
        paymentLedgers,
        associationReport,
        categoryPerformance,
      ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:rmss/features/admin/models/reports/association_report.dart';
import 'package:rmss/features/admin/models/reports/category_performance_report.dart';
import 'package:rmss/features/admin/models/reports/item_importance_report.dart';
import 'package:rmss/features/admin/models/reports/payment_processing_ledger.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {}

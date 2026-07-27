import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadReports({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

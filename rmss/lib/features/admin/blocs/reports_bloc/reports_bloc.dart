import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/repository/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository reportsRepository;

  ReportsBloc({required this.reportsRepository}) : super(ReportsInitial()) {
    on<LoadReports>((event, emit) async {
      emit(ReportsLoading());
      try {
        final data = await reportsRepository.generateAllReports();

        emit(
          ReportsLoaded(
            itemImportanceReports: data['itemImportanceReports'],
            paymentLedgers: data['paymentLedgers'],
            associationReport: data['associationReport'],
            categoryPerformance: data['categoryPerformance'],
          ),
        );
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });
  }
}

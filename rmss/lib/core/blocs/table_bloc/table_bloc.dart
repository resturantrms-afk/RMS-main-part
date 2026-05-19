import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/repositories/table_repository.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableRepository _repository;

  TableBloc({required TableRepository repository})
    : _repository = repository,
      super(TableInitial()) {
    on<AddTable>((event, emit) async {
      try {
        await _repository.addTable(event.item);
      } on FirebaseException catch (e) {
        emit(TableError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(TableError(message: e.toString()));
      }
    });

    on<UpdateTable>((event, emit) async {
      try {
        await _repository.updateTable(event.item);
      } on FirebaseException catch (e) {
        emit(TableError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(TableError(message: e.toString()));
      }
    });

    on<DeleteTable>((event, emit) async {
      try {
        await _repository.deleteTable(event.item);
      } on FirebaseException catch (e) {
        emit(TableError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(TableError(message: e.toString()));
      }
    });

    on<LoadTables>((event, emit) async {
      emit(TablesLoading());

      // emit.forEach listens to the stream forever, and emits a new MenuLoaded state
      // every single time Firebase pushes new data!
      await emit.forEach<List<TableModel>>(
        _repository.getTables(),
        onData: (items) => TablesLoaded(items: items),
        onError: (error, stackTrace) => TableError(message: error.toString()),
      );
    });
  }
}

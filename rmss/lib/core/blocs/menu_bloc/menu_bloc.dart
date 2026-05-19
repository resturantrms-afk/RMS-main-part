import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/repositories/menu_repository.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _repository;

  MenuBloc({required MenuRepository repository})
    : _repository = repository,
      super(MenuInitial()) {
    on<AddMenuItem>((event, emit) async {
      try {
        await _repository.addMenuItem(event.item);
      } on FirebaseException catch (e) {
        emit(MenuError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(MenuError(message: e.toString()));
      }
    });

    on<UpdateMenuItem>((event, emit) async {
      try {
        await _repository.updateMenuItem(event.item);
      } on FirebaseException catch (e) {
        emit(MenuError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(MenuError(message: e.toString()));
      }
    });

    on<DeleteMenuItem>((event, emit) async {
      try {
        await _repository.deleteMenuItem(event.item);
      } on FirebaseException catch (e) {
        emit(MenuError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(MenuError(message: e.toString()));
      }
    });

    on<LoadMenu>((event, emit) async {
      emit(MenuLoading());

      // emit.forEach listens to the stream forever, and emits a new MenuLoaded state
      // every single time Firebase pushes new data!
      await emit.forEach<List<MenuItemModel>>(
        _repository.getMenuItems(),
        onData: (items) => MenuLoaded(items: items),
        onError: (error, stackTrace) => MenuError(message: error.toString()),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc({required OrderRepository repository})
    : _repository = repository,
      super(OrderInitial()) {
    on<AddOrder>((event, emit) async {
      try {
        await _repository.addOrder(event.item);
      } on FirebaseException catch (e) {
        emit(OrderError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(OrderError(message: e.toString()));
      }
    });

    on<UpdateOrder>((event, emit) async {
      try {
        await _repository.updateOrder(event.item);
      } on FirebaseException catch (e) {
        emit(OrderError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(OrderError(message: e.toString()));
      }
    });

    on<DeleteOrder>((event, emit) async {
      try {
        await _repository.deleteOrder(event.item);
      } on FirebaseException catch (e) {
        emit(OrderError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(OrderError(message: e.toString()));
      }
    });

    on<LoadOrder>((event, emit) async {
      emit(OrderLoading());

      // emit.forEach listens to the stream forever, and emits a new MenuLoaded state
      // every single time Firebase pushes new data!
      await emit.forEach<List<OrderModel>>(
        _repository.getOrders(),
        onData: (items) => OrderLoaded(items: items),
        onError: (error, stackTrace) => OrderError(message: error.toString()),
      );
    });
  }
}

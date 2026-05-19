import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_event.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/repositories/payment_repository.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  PaymentBloc({required PaymentRepository repository})
    : _repository = repository,
      super(PaymentInitial()) {
    on<AddPayment>((event, emit) async {
      try {
        await _repository.addPayment(event.item);
      } on FirebaseException catch (e) {
        emit(PaymentError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(PaymentError(message: e.toString()));
      }
    });

    on<UpdatePayment>((event, emit) async {
      try {
        await _repository.updatePayments(event.item);
      } on FirebaseException catch (e) {
        emit(PaymentError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(PaymentError(message: e.toString()));
      }
    });

    on<DeletePayment>((event, emit) async {
      try {
        await _repository.deletePayment(event.item);
      } on FirebaseException catch (e) {
        emit(PaymentError(message: e.message ?? "Unknown Error"));
      } catch (e) {
        emit(PaymentError(message: e.toString()));
      }
    });

    on<LoadPayments>((event, emit) async {
      emit(PaymentsLoading());

      // emit.forEach listens to the stream forever, and emits a new MenuLoaded state
      // every single time Firebase pushes new data!
      await emit.forEach<List<PaymentModel>>(
        _repository.getPayments(),
        onData: (items) => PaymentsLoaded(items: items),
        onError: (error, stackTrace) => PaymentError(message: error.toString()),
      );
    });
  }
}

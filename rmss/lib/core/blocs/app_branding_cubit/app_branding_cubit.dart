import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/models/app_branding_model.dart';
import 'package:rmss/core/repositories/app_branding_repository.dart';

class AppBrandingCubit extends Cubit<AppBrandingModel> {
  final AppBrandingRepository _repository;
  StreamSubscription? _subscription;

  AppBrandingCubit({required AppBrandingRepository repository}) 
    : _repository = repository, 
      super(const AppBrandingModel(appName: 'Restaurant Management', appLogoUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80')) {
    _subscription = _repository.getBrandingStream().listen((branding) {
      emit(branding);
    });
  }

  Future<void> updateBranding(String name, String logoUrl, String brandColorHex) async {
    await _repository.updateBranding(AppBrandingModel(appName: name, appLogoUrl: logoUrl, brandColorHex: brandColorHex));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

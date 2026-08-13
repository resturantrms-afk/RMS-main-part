import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_event.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_state.dart';
import 'package:rmss/core/repositories/menu_profile_repository.dart';

class MenuProfileBloc extends Bloc<MenuProfileEvent, MenuProfileState> {
  final MenuProfileRepository _repository;
  StreamSubscription? _subscription;

  MenuProfileBloc({required MenuProfileRepository repository})
      : _repository = repository,
        super(MenuProfileLoading()) {
    on<LoadMenuProfiles>(_onLoadMenuProfiles);
    on<UpdateMenuProfilesList>(_onUpdateMenuProfilesList);
    on<AddMenuProfile>(_onAddMenuProfile);
    on<UpdateMenuProfile>(_onUpdateMenuProfile);
    on<DeleteMenuProfile>(_onDeleteMenuProfile);
    on<ToggleMenuProfileActiveStatus>(_onToggleMenuProfileActiveStatus);
  }

  void _onLoadMenuProfiles(LoadMenuProfiles event, Emitter<MenuProfileState> emit) {
    emit(MenuProfileLoading());
    _subscription?.cancel();
    _subscription = _repository.getMenuProfiles().listen(
      (profiles) {
        add(UpdateMenuProfilesList(profiles));
      },
      onError: (error) {
        emit(MenuProfileError(message: error.toString()));
      },
    );
  }

  void _onUpdateMenuProfilesList(UpdateMenuProfilesList event, Emitter<MenuProfileState> emit) {
    emit(MenuProfilesLoaded(profiles: event.profiles));
  }

  Future<void> _onAddMenuProfile(AddMenuProfile event, Emitter<MenuProfileState> emit) async {
    try {
      await _repository.addMenuProfile(event.profile);
    } catch (e) {
      emit(MenuProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMenuProfile(UpdateMenuProfile event, Emitter<MenuProfileState> emit) async {
    try {
      await _repository.updateMenuProfile(event.profile);
    } catch (e) {
      emit(MenuProfileError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMenuProfile(DeleteMenuProfile event, Emitter<MenuProfileState> emit) async {
    try {
      await _repository.deleteMenuProfile(event.profile);
    } catch (e) {
      emit(MenuProfileError(message: e.toString()));
    }
  }

  Future<void> _onToggleMenuProfileActiveStatus(
      ToggleMenuProfileActiveStatus event, Emitter<MenuProfileState> emit) async {
    if (state is MenuProfilesLoaded) {
      try {
        // 1. Update the profile status in DB
        final updatedProfile = event.profile.copyWith(isActive: event.isActive);
        await _repository.updateMenuProfile(updatedProfile);

        // 2. We need to sync items. To ensure sync happens with the *new* state
        // before the stream updates the state, we can compute the new profiles list manually
        final currentProfiles = (state as MenuProfilesLoaded).profiles;
        final newProfiles = currentProfiles.map((p) => p.id == updatedProfile.id ? updatedProfile : p).toList();

        // 3. Batch update the menu items
        await _repository.syncActiveProfilesToMenuItems(newProfiles, event.allCurrentMenuItems);
      } catch (e) {
        emit(MenuProfileError(message: e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:remind_me/blocs/settings/settings_event.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<UpdateThemeModeEvent>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) => SettingsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => state.toJson();
}

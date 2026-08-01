import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectFormState {
  final String? name;
  final String? gender;
  final String? office;
  final String? country;
  final String? state;
  final String? city;
  final String? phoneNumber;
  final String? projectName;
  final String? error;

  ProjectFormState({
    this.name,
    this.gender,
    this.office,
    this.country,
    this.state,
    this.city,
    this.phoneNumber,
    this.projectName,
    this.error,
  });

  ProjectFormState copyWith({
    String? name,
    String? gender,
    String? office,
    String? country,
    String? state,
    String? city,
    String? phoneNumber,
    String? projectName,
    String? error,
  }) {
    return ProjectFormState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      office: office ?? this.office,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      projectName: projectName ?? this.projectName,
      error: error ?? this.error,
    );
  }
}

class ProjectFormNotifier extends StateNotifier<ProjectFormState> {
  ProjectFormNotifier() : super(ProjectFormState());

  void updateField({String? name, String? gender, String? office, String? projectName, String? phoneNumber}) {
    state = state.copyWith(
      name: name ?? state.name,
      gender: gender ?? state.gender,
      office: office ?? state.office,
      projectName: projectName ?? state.projectName,
      phoneNumber: phoneNumber ?? state.phoneNumber,
    );
  }

  void updateError(String errorMessage) {
    state = state.copyWith(error: errorMessage);
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}

final projectFormProvider = StateNotifierProvider<ProjectFormNotifier, ProjectFormState>((ref) {
  return ProjectFormNotifier();
});

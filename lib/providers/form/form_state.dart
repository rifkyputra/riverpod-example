import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FormFieldState {
  loading,
  error,
  ok,
}

class FormState {
  final List<FormField> fields;

  FormState(this.fields);
}

extension ListFormField on List<FormField> {
  get isAnyError => any((item) => item.fieldState == FormFieldState.error);

  bool get isReadyToSubmit => every((element) {
        final isValidate = element.validation?.call(element.value) ?? true;

        if (!isValidate) {
          return false;
        }

        if (element.isMandatory) {
          return element.value != null;
        }

        return true;
      });

  FormField getByKey(String key) => firstWhere((element) => element.key == key);
  List<FormField> setByKey(String key, FormField value) =>
      [for (var e in this) e.key == key ? value : e];

  bool get hasMandatory => any((item) => item.isMandatory);
  Map<String, dynamic> get values => {
        for (var e in this) e.key: e.value,
      };
}

class FormField<T> {
  final FormFieldState fieldState;
  final bool isMandatory;
  final String key;
  final T value;
  final bool enable;
  final bool Function(dynamic)? validation;

  FormField({
    required this.key,
    this.isMandatory = false,
    required this.value,
    this.validation,
    this.fieldState = FormFieldState.loading,
    this.enable = true,
  });

  FormField<T> addValue(newValue) {
    return FormField<T>(
      key: key,
      value: newValue,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
    );
  }

  FormField<T> disabled() {
    return FormField<T>(
      key: key,
      value: value,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
      enable: false,
    );
  }

  FormField<T> enabled() {
    return FormField<T>(
      key: key,
      value: value,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
      enable: true,
    );
  }
}

class FormProvider extends StateNotifier<FormState> {
  FormProvider(state) : super(state);

  void fillValue(String key, value) => state = FormState(
        [for (var e in state.fields) e.key == key ? e.addValue(value) : e],
      );
}

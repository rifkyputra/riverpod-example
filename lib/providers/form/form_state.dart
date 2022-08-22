import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FormFieldState {
  loading,
  error,
  ok,
}

enum FormModelStatus {
  submitted,
  submitting,
  none,
}

class FormModel {
  final List<FormFieldItem> fields;
  final FormModelStatus formStatus;

  FormModel(
    this.fields, {
    this.formStatus = FormModelStatus.none,
  });

  FormModel setFormStatus(FormModelStatus status) =>
      FormModel(fields, formStatus: status);
}

extension ListFormField on List<FormFieldItem> {
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

  FormFieldItem getByKey(String key) =>
      firstWhere((element) => element.key == key);
  List<FormFieldItem> setByKey(String key, FormFieldItem value) =>
      [for (var e in this) e.key == key ? value : e];

  bool get hasMandatory => any((item) => item.isMandatory);
  Map<String, dynamic> get values => {
        for (var e in this) e.key: e.value,
      };
}

class FormFieldItem<T> {
  final FormFieldState fieldState;
  final bool isMandatory;
  final String key;
  final T value;
  final bool enable;
  final bool Function(dynamic)? validation;
  final T defaultValue;

  FormFieldItem({
    required this.key,
    this.isMandatory = false,
    required this.value,
    this.validation,
    this.fieldState = FormFieldState.loading,
    this.enable = true,
  }) : defaultValue = value;

  FormFieldItem<T> editValue(T newValue) {
    return FormFieldItem<T>(
      key: key,
      value: newValue,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
      enable: enable,
    );
  }

  FormFieldItem<T> disabled() {
    return FormFieldItem<T>(
      key: key,
      value: value,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
      enable: false,
    );
  }

  FormFieldItem<T> enabled() {
    return FormFieldItem<T>(
      key: key,
      value: value,
      fieldState: fieldState,
      isMandatory: isMandatory,
      validation: validation,
      enable: true,
    );
  }
}

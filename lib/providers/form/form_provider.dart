import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/form/form_state.dart';

final formChangeProvider =
    StateNotifierProvider.autoDispose<FormProvider, FormState>(
  (ref) => FormProvider(
    FormState([
      FormField<String?>(
        key: 'title',
        value: null,
        isMandatory: true,
        validation: (s) => s?.isNotEmpty ?? false,
      ),
      FormField<String?>(
        key: 'description',
        value: null,
      ),
      FormField<String?>(
        key: 'nickname',
        value: null,
      ),
      FormField<String?>(
        key: 'nominal',
        value: null,
        isMandatory: true,
        validation: (s) => s?.isNotEmpty ?? false,
      ),
    ]),
  ),
);
final formProvider = StateNotifierProvider.autoDispose<FormProvider, FormState>(
  (ref) {
    var form = ref.watch(formChangeProvider).fields;

    var title = form.getByKey('title');
    var description = form.getByKey('description');
    var nickname = form.getByKey('nickname');
    var nominal = form.getByKey('nominal');

    form = form
        .setByKey(
          'description',
          title.value == null || title.value.toString().isEmpty
              ? description.disabled()
              : description.enabled(),
        )
        .setByKey(
          'nickname',
          (description.value == null || description.value.toString().isEmpty)
              ? nickname.disabled()
              : nickname.enabled(),
        )
        .setByKey(
          'nominal',
          (nickname.value == null || nickname.value.toString().isEmpty)
              ? nominal.disabled()
              : nominal.enabled(),
        );

    return FormProvider(FormState(form));
  },
);

final checkField = StateProvider.autoDispose<FormField>(
    (ref) => FormField(key: 'agree', value: false));

final enabledProvider = StateProvider.autoDispose<bool>((ref) {
  final hasAgree = ref.watch(checkField).value == true;
  final mandatoryFieldsReady = ref.watch(formProvider).fields.isReadyToSubmit;

  if (hasAgree && mandatoryFieldsReady) return true;

  return false;
});

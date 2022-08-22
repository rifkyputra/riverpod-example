import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/form/form_state.dart';

class CompleteProfileFormProvider extends StateNotifier<FormModel> {
  CompleteProfileFormProvider(FormModel formModel) : super(formModel);

  void fillValue(String key, value) => state = FormModel(
        [for (var e in state.fields) e.key == key ? e.editValue(value) : e],
      );

  void resetValues() => state = FormModel(
        [for (var e in state.fields) e.editValue(e.defaultValue)],
      );

  void saveToFirestore() async {
    state = state.setFormStatus(FormModelStatus.submitting);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(state.fields.getByKey('email').value)
          .set(state.fields.values);
      state = state.setFormStatus(FormModelStatus.submitted);
    } catch (e) {
      state = state.setFormStatus(FormModelStatus.none);

      //
    }
  }
}

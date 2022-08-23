import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/providers/complete_profile/complete_profile_provider.dart';
import 'package:tryriverpod/providers/form/form_state.dart';
import 'package:tryriverpod/screen/form.dart';

final completeProfileFormChangerProvider =
    StateNotifierProvider.autoDispose<CompleteProfileFormProvider, FormModel>(
  (ref) => CompleteProfileFormProvider(FormModel([
    FormFieldItem<String>(
      key: 'email',
      value: '',
      isMandatory: true,
      enable: false,
    ),
    FormFieldItem<String>(
      key: 'name',
      value: '',
      isMandatory: true,
    ),
    FormFieldItem<String>(
      key: 'phone',
      value: '',
      isMandatory: true,
    ),
  ])),
);

final completeProfileForm =
    StateNotifierProvider.autoDispose<CompleteProfileFormProvider, FormModel>(
        (ref) {
  var fields = ref.watch(completeProfileFormChangerProvider).fields;
  final String? email = ref.watch(appSetupProvider).asData?.value.user?.email;
  print('email :::: $email');

  if (email != null) {
    fields =
        fields.setByKey('email', fields.getByKey('email').editValue(email));
  }

  return CompleteProfileFormProvider(FormModel(fields));
});

final getUserRelations =
    StreamProvider.family<List<QueryDocumentSnapshot>, String>(
        (ref, email) async* {
  final firestore = FirebaseFirestore.instance;

  final stream = firestore
      .collection('users')
      .doc(email)
      .collection('relations')
      .snapshots();

  await for (var s in stream) {
    yield (s.docs);
  }
});

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, _) {
                if (ref.watch(completeProfileForm).formStatus ==
                    FormModelStatus.submitted) {
                  Navigator.of(context).pop();
                }
                final String email = ref
                    .watch(completeProfileForm)
                    .fields
                    .getByKey('email')
                    .value;

                return Form(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text('email'),
                        EnabledWidget(
                          enable: email.isEmpty,
                          child: TextFormField(
                            initialValue: email,
                            onChanged: (v) => ref
                                .read(
                                    completeProfileFormChangerProvider.notifier)
                                .fillValue('email', v),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text('name'),
                        TextFormField(
                          onChanged: (v) => ref
                              .read(completeProfileFormChangerProvider.notifier)
                              .fillValue('name', v),
                        ),
                        const SizedBox(height: 22),
                        const Text('phone'),
                        TextFormField(
                          onChanged: (v) => ref
                              .read(completeProfileFormChangerProvider.notifier)
                              .fillValue('phone', v),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(completeProfileForm.notifier)
                                  .saveToFirestore();
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ]),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

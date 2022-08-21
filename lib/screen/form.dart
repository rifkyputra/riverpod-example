import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/form/form_provider.dart';
import 'package:tryriverpod/providers/form/form_state.dart';

class FormPage extends StatelessWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: const [
        FormBuilder(),
      ]),
    );
  }
}

class FormBuilder extends StatelessWidget {
  const FormBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                return Column(children: [
                  for (var e in ref.watch(formProvider).fields)
                    EnabledWidget(
                      enable: e.enable,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 38),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key),
                            TextFormField(
                              onChanged: (t) => ref
                                  .read(formChangeProvider.notifier)
                                  .fillValue(e.key, t),
                            ),
                          ],
                        ),
                      ),
                    ),
                  EnabledWidget(
                    enable: ref.watch(checkField).validation?.call('') ?? true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('agree'),
                        Checkbox(
                            value: ref.watch(checkField).value as bool,
                            onChanged: (val) =>
                                ref.read(checkField.notifier).state = ref
                                    .read(checkField.notifier)
                                    .state
                                    .addValue((val ?? false)))
                      ],
                    ),
                  ),
                  EnabledWidget(
                    enable: ref.watch(enabledProvider),
                    child: ElevatedButton(
                        onPressed: () {
                          final values = ref.read(formProvider).fields.values
                            ..addAll({
                              'agree': ref.read(checkField).value,
                            });

                          debugPrint(values.toString());
                        },
                        child: const Text('Save')),
                  )
                ]);
              },
            )
          ],
        ),
      ),
    );
  }
}

class EnabledWidget extends StatelessWidget {
  const EnabledWidget({Key? key, this.enable = false, required this.child})
      : super(key: key);
  final bool enable;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: !enable,
        child: Opacity(opacity: enable ? 1 : .5, child: child),
      );
}

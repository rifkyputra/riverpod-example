import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/form/form_provider.dart';
import 'package:tryriverpod/providers/form/form_state.dart';

final listResult = StateProvider<List<Map<String, dynamic>>>((ref) => []);

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
              builder: (context, ref, _) {
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
                  Consumer(builder: (context, ref, _) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await showSearch(
                            context: context,
                            delegate:
                                CustomSearchHintDelegate(hintText: 'hint'));

                        ref
                            .read(listResult.notifier)
                            .update((state) => [...state, result!]);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Person Involved'),
                          ListView(
                            shrinkWrap: true,
                            children: ref
                                .watch(listResult)
                                .map<Widget>(
                                  (e) => ListTile(
                                    leading: IconButton(
                                      onPressed: () {
                                        ref
                                            .read(listResult.notifier)
                                            .update((state) {
                                          state.removeWhere((element) =>
                                              element['name'] == e['name']);
                                          return List.from(state);
                                        });
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                    title: Text(e['name']),
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      ),
                    );
                  }),
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
                                    .editValue((val ?? false)))
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

class CustomSearchHintDelegate extends SearchDelegate<Map<String, dynamic>> {
  CustomSearchHintDelegate({
    required String hintText,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  final suggestion = [
    {
      'name': 'pesulap merah',
    },
    {
      'name': 'livy',
    },
    {
      'name': 'sambo',
    },
    {
      'name': 'bevy',
    },
  ];

  @override
  Widget buildLeading(BuildContext context) => const Text('leading');

  @override
  PreferredSizeWidget buildBottom(BuildContext context) {
    return const PreferredSize(
        preferredSize: Size.fromHeight(56.0), child: Text('bottom'));
  }

  @override
  Widget buildSuggestions(BuildContext context) => Builder(builder: (context) {
        final list = suggestion
            .where((element) => element['name']!.contains(query))
            .toList();
        print(query);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('results'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(list[index]);
                  },
                  title: Text(list[index]['name'].toString()),
                );
              },
            )
          ],
        );
      });

  @override
  Widget buildResults(BuildContext context) => Builder(builder: (context) {
        final list =
            suggestion.where((element) => element['name'] == query).toList();
        print(list);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('results'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(list[index]['name'].toString()),
                );
              },
            )
          ],
        );
      });

  @override
  List<Widget> buildActions(BuildContext context) => <Widget>[Icon(Icons.abc)];
}

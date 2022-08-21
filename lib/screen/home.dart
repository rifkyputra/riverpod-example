import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/screen/form.dart';
import 'package:tryriverpod/services/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';

extension HiveExtension on StreamProvider<AppSetupModel> {
  Future<T?> get<T>({
    required String key,
    required Ref ref,
    required String collection,
    required String box,
  }) async {
    return (await ((ref.read(this).asData!.value)
            .collection[collection]!
            .openBox<T>(box)))
        .get(key);
  }

  Future<void> put<T>({
    required String key,
    required Ref ref,
    required String collection,
    required String box,
    required T data,
  }) async {
    return (await ((ref.read(this).asData!.value)
            .collection[collection]!
            .openBox<T>(box)))
        .put(key, data);
  }
}

final counter = FutureProvider.autoDispose<int?>((ref) async {
  ref.watch(savingValue);

  return await appSetupProvider.get<int?>(
    key: 'currents',
    box: DBBoxes.intCounter,
    collection: DBCollections.counterColl,
    ref: ref,
  );
});

final savingValue = FutureProvider.autoDispose<bool>(
  (ref) async {
    final count = ref.watch(onTapValue);

    if (count == null) return false;

    await appSetupProvider.put<int?>(
      key: 'currents',
      ref: ref,
      collection: DBCollections.counterColl,
      box: DBBoxes.intCounter,
      data: count,
    );

    return true;
  },
);

final onTapValue = StateProvider.autoDispose<int?>((ref) => null);

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      ref.watch(savingValue);
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Home'),
            CounterWidget(),
            SizedBox(height: 10),
            ResetWidget(),
            SizedBox(height: 10),
            GoToForm(),
          ],
        ),
      );
    });
  }
}

class ResetWidget extends ConsumerWidget {
  const ResetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(onTapValue.notifier).state = 0;
      },
      child: const Text(' Reset '),
    );
  }
}

class CounterWidget extends ConsumerWidget {
  const CounterWidget({Key? key}) : super(key: key);

  int getCounterValue(WidgetRef ref) =>
      ref.watch(counter).asData?.value ?? ref.watch(onTapValue) ?? 0;

  @override
  Widget build(BuildContext context, ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            final value = getCounterValue(ref);
            if (value <= 0) return;

            ref.read(onTapValue.notifier).state = value - 1;
          },
          child: const Text(' - '),
        ),
        const SizedBox(width: 10),
        ResultDisplay(
          // key: Key(getCounterValue(ref).toString()),
          onChange: (t) => ref.read(onTapValue.notifier).state = int.parse(t),
          text: getCounterValue(ref).toString(),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            ref.read(onTapValue.notifier).state = getCounterValue(ref) + 1;
          },
          child: const Text(' + '),
        ),
      ],
    );
  }
}

class ResultDisplay extends StatefulWidget {
  const ResultDisplay({Key? key, required this.text, required this.onChange})
      : super(key: key);

  final String text;
  final Function(String) onChange;

  @override
  State<ResultDisplay> createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay>
    with WidgetsBindingObserver {
  bool input = false;
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus) {
          setState(() {
            input = !input;
          });
        }
      });
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          input = !input;
        });
      },
      child: input
          ? SizedBox(
              width: 40,
              child: TextField(
                autofocus: true,
                controller: _textEditingController,
                onChanged: widget.onChange,
                focusNode: _focusNode,
                onSubmitted: (_) {
                  setState(() {
                    input = !input;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    input = !input;
                  });
                },
              ),
            )
          : Text(widget.text),
    );
  }
}

class GoToForm extends StatelessWidget {
  const GoToForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FormPage()),
      ),
      child: const Text('Go To Dynamic Form'),
    );
  }
}

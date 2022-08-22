import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/counter/counter_provider.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      ref.watch(savingValue);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CounterWidget(),
          SizedBox(height: 10),
          ResetWidget(),
          SizedBox(height: 10),
        ],
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
          onChange: (t) =>
              ref.read(onTapValue.notifier).state = int.tryParse(t),
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
  const ResultDisplay({
    Key? key,
    required this.text,
    required this.onChange,
  }) : super(key: key);

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
    _textEditingController = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textEditingController = TextEditingController(text: widget.text);
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

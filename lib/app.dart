
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/screen/home.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';


class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Consumer(builder: (context, ref, _) {
        return MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ref.watch(appSetupProvider).when<Widget>(
                      data: (_) => const HomePage(),
                      error: (_, __) => const ErrorSetup(),
                      loading: () => const LoadingSplash(),
                    );
              },
            ),
          ),
        );
      }),
    );
  }
}

class LoadingSplash extends StatelessWidget {
  const LoadingSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ErrorSetup extends StatelessWidget {
  const ErrorSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Something went wrong'));
  }
}
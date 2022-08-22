import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: Column(children: [
        ElevatedButton(
            child: Text('Google Sign In'),
            onPressed: () =>
                ref.read(appSetupServiceProvider).signInWithGoogle())
      ]),
    );
  }
}

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/screen/form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(appSetupProvider).whenData((value) {
      if (value.user != null) {
        BotToast.showText(text: 'Telah Login..');

        Future.delayed(Duration(seconds: 2), () async {
          Navigator.of(context).pop();
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: EnabledWidget(
                enable: ref.watch(appSetupProvider).asData?.value.user == null,
                child: ElevatedButton(
                  child: Text('Google Sign In, mengalihkan...'),
                  onPressed: () =>
                      ref.read(appSetupServiceProvider).signInWithGoogle(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

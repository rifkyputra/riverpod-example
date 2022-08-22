import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/screen/complete_profile.dart';
import 'package:tryriverpod/screen/counter.dart';
import 'package:tryriverpod/screen/form.dart';
import 'package:tryriverpod/screen/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Consumer(builder: (context, ref, __) {
              String? name;

              ref.watch(appSetupProvider).whenData((value) {
                if (value.user != null && value.user!.email != null) {
                  name = value.user!.email!;
                }
              });

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text('Hello, ${name ?? "Guest"}'),
                    if (name != null)
                      TextButton(
                        child: Text('Sign Out'),
                        onPressed: () {
                          ref.read(appSetupServiceProvider).signOut();
                        },
                      )
                  ],
                ),
              );
            }),
          ),
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Home'),
                  CounterScreen(),
                  SizedBox(height: 12),
                  GoToForm(),
                  SizedBox(height: 12),
                  GoToComProf(),
                  SizedBox(height: 12),
                  GoToSignIn(),
                ],
              ),
            ),
          ),
        ],
      ),
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

class GoToComProf extends StatelessWidget {
  const GoToComProf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      ),
      child: const Text('Go To Complete Profile'),
    );
  }
}

class GoToSignIn extends StatelessWidget {
  const GoToSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
      child: const Text('Sign In'),
    );
  }
}

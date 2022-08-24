import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';

final appSetupServiceProvider = Provider(
  (ref) => AppSetupService(),
);

final googleProvider = Provider(
  (ref) => GoogleAuthProvider(),
);

final appSetupModelProvider = Provider(
  (ref) => AppSetupModel(collection: {}),
);

final appSetupProvider = StreamProvider<AppSetupModel>((ref) async* {
  // watch for firebase config changes
  // watch for auth changes

  final appService = ref.watch(appSetupServiceProvider).initialize();
  final auth = ref.watch(appSetupServiceProvider).listenAuth();
  AppSetupModel? appSetupModel = ref.state.asData?.value;

  await for (AppSetupModel model in appService) {
    appSetupModel = appSetupModel?.merge(model) ?? model;
    yield (appSetupModel);
  }

  await for (User? user in auth) {
    appSetupModel = appSetupModel?.copyWith(user: user) ??
        AppSetupModel(
          collection: {},
          user: user,
        );

    print('------->>> ${appSetupModel.user?.email}');
    yield (appSetupModel);
  }
});

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

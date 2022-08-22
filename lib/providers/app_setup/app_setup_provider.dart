import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';

final appSetupServiceProvider = Provider(
  (ref) => AppSetupService(),
);

final googleProvider = Provider(
  (ref) => GoogleAuthProvider(),
);

final appSetupProvider = StreamProvider<AppSetupModel>((ref) async* {
  // watch for firebase config changes
  // watch for auth changes

  final appService = ref.watch(appSetupServiceProvider).initialize();

  await for (AppSetupModel model in appService) {
    yield (model);
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

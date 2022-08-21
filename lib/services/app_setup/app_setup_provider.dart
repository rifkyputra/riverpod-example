import 'package:riverpod/riverpod.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';

final appSetupProvider = StreamProvider<AppSetupModel>((ref) async* {
  // watch for firebase config changes
  // watch for auth changes

  await for (AppSetupModel model in AppSetupService().initialize()) {
    yield (model);
  }
});

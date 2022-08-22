import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';

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

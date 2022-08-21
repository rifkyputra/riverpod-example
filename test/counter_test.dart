import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tryriverpod/app.dart';
import 'package:tryriverpod/screen/home.dart';
import 'package:tryriverpod/services/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/services/app_setup/app_setup_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBoxCollection extends Mock implements BoxCollection {}

class MockCollectionBox<V> extends Mock implements CollectionBox<V> {}

final _mockBoxColl = MockBoxCollection();
final _mockCollBox = MockCollectionBox<int?>();

void main() async {
  when(
    () => _mockBoxColl.openBox(any()),
  ).thenAnswer((_) async => _mockCollBox);

  when(
    () => _mockCollBox.put(any(), any()),
  ).thenAnswer((_) async {});

  testWidgets(
    'find one',
    (widgetTester) async {
      when(
        () => _mockCollBox.get(any()),
      ).thenAnswer((_) async => 0);

      await pumpWidget(widgetTester);

      expectLater(find.byType(RootApp), findsOneWidget);
      expectLater(find.text('0'), findsOneWidget);
    },
  );

  testWidgets(
    'increase',
    (widgetTester) async {
      when(
        () => _mockCollBox.get(any()),
      ).thenAnswer((_) async => 1);

      await pumpWidget(
        widgetTester,
        overrides: [
          counter.overrideWithValue(const AsyncValue.data(1)),
        ],
      );
      await widgetTester.tap(find.textContaining('+'));
      // verify(() => ref.read())

      expectLater(find.textContaining('1'), findsOneWidget);
    },
  );
}

pumpWidget(WidgetTester tester, {List<Override>? overrides}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSetupProvider.overrideWithValue(AsyncValue.data(
          AppSetupModel(
            collection: {DBCollections.counterColl: _mockBoxColl},
          ),
        )),
        ...?overrides,
      ],
      child: const MaterialApp(
        home: RootApp(),
      ),
    ),
  );
}

import 'package:first_lab/main.dart';
import 'package:first_lab/modules/counter/counter_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _readAssetName(WidgetTester tester) {
  final imageFinder = find.byType(Image);
  expect(imageFinder, findsOneWidget);
  final image = tester.widget<Image>(imageFinder);
  final provider = image.image as AssetImage;
  return provider.assetName;
}

String _readTextByKey(WidgetTester tester, String keyValue) {
  final textFinder = find.byKey(Key(keyValue));
  expect(textFinder, findsOneWidget);
  final textWidget = tester.widget<Text>(textFinder);
  return textWidget.data ?? '';
}

void main() {
  testWidgets('counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('cycles through three images before unlock', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(_readAssetName(tester), CounterModule.stageImagePaths[0]);

    final incrementButton = find.byIcon(Icons.add);

    await tester.tap(incrementButton);
    await tester.pumpAndSettle();
    expect(_readAssetName(tester), CounterModule.stageImagePaths[1]);

    await tester.tap(incrementButton);
    await tester.pumpAndSettle();
    expect(_readAssetName(tester), CounterModule.stageImagePaths[2]);

    await tester.tap(incrementButton);
    await tester.pumpAndSettle();
    expect(_readAssetName(tester), CounterModule.stageImagePaths[0]);
  });

  testWidgets('shows fourth image at 20 counter', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final incrementButton = find.byIcon(Icons.add);

    for (var i = 0; i < CounterModule.unlockThreshold; i++) {
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('20'), findsOneWidget);
    expect(
      _readTextByKey(tester, 'unlock_status'),
      'Threshold reached. The fourth image is active.',
    );
    expect(_readAssetName(tester), CounterModule.unlockedImagePath);
  });

  testWidgets('tap on image resets counter', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final incrementButton = find.byIcon(Icons.add);
    for (var i = 0; i < 5; i++) {
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('5'), findsOneWidget);
    expect(_readAssetName(tester), CounterModule.stageImagePaths[2]);

    await tester.tap(find.byKey(const Key('counter_image')));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(_readAssetName(tester), CounterModule.stageImagePaths[0]);
  });
}

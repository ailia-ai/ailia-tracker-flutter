// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ailia_tracker/ailia_tracker_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tracker keeps the same id across frames',
      (WidgetTester tester) async {
    final tracker = AiliaTrackerModel();
    tracker.create();

    int? trackedId;
    for (int frame = 0; frame < 3; frame++) {
      tracker.addTarget(AiliaTrackerTarget(
        category: 0,
        prob: 0.9,
        x: 0.1 + frame * 0.01,
        y: 0.1,
        w: 0.2,
        h: 0.4,
      ));
      final objects = tracker.compute();
      expect(objects.length, 1);
      trackedId ??= objects[0].id;
      expect(objects[0].id, trackedId);
    }

    tracker.close();
  });
}

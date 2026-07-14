import 'package:flutter_test/flutter_test.dart';
import 'package:ailia_tracker/ailia_tracker_model.dart';

void main() {
  // The tracker requires the native library, so the actual behavior is
  // verified with the integration test in the example app.
  test('AiliaTrackerModel is not available before create', () {
    final tracker = AiliaTrackerModel();
    expect(tracker.available, false);
  });
}

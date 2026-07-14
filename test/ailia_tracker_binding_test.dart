// Binding test using the bundled native library.
// Runs on desktop (macOS / Linux / Windows) via `flutter test`.

@TestOn('mac-os || linux || windows')
library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailia_tracker/ailia_tracker.dart' as ailia_tracker_dart;

String trackerLibraryPath() {
  if (Platform.isMacOS) {
    return 'macos/libailia_tracker.dylib';
  }
  if (Platform.isWindows) {
    return 'windows/x64/ailia_tracker.dll';
  }
  return 'linux/x64/libailia_tracker.so';
}

void main() {
  test('create / addTarget / compute / getObject / destroy', () {
    final lib = DynamicLibrary.open(trackerLibraryPath());
    final ffi = ailia_tracker_dart.ailiaTrackerFFI(lib);

    final ppTracker = malloc<Pointer<ailia_tracker_dart.AILIATracker>>();
    final settings = malloc<ailia_tracker_dart.AILIATrackerSettings>();
    settings.ref.score_threshold = 0.1;
    settings.ref.nms_threshold = 0.7;
    settings.ref.track_threshold = 0.5;
    settings.ref.track_buffer = 30;
    settings.ref.match_threshold = 0.8;

    int status = ffi.ailiaTrackerCreate(
      ppTracker,
      ailia_tracker_dart.AILIA_TRACKER_ALGORITHM_BYTE_TRACK,
      settings,
      ailia_tracker_dart.AILIA_TRACKER_SETTINGS_VERSION,
      ailia_tracker_dart.AILIA_TRACKER_FLAG_NONE,
    );
    malloc.free(settings);
    expect(status, 0, reason: 'ailiaTrackerCreate');

    int? trackedId;

    // Simulate 3 frames with one object moving slightly.
    for (int frame = 0; frame < 3; frame++) {
      final det = malloc<ailia_tracker_dart.AILIADetectorObject>();
      det.ref.category = 0;
      det.ref.prob = 0.9;
      det.ref.x = 0.1 + frame * 0.01;
      det.ref.y = 0.1;
      det.ref.w = 0.2;
      det.ref.h = 0.4;
      status = ffi.ailiaTrackerAddTarget(ppTracker.value, det, 1);
      malloc.free(det);
      expect(status, 0, reason: 'ailiaTrackerAddTarget frame $frame');

      status = ffi.ailiaTrackerCompute(ppTracker.value);
      expect(status, 0, reason: 'ailiaTrackerCompute frame $frame');

      final count = malloc<UnsignedInt>();
      status = ffi.ailiaTrackerGetObjectCount(ppTracker.value, count);
      expect(status, 0, reason: 'ailiaTrackerGetObjectCount frame $frame');
      expect(count.value, 1, reason: 'one tracked object in frame $frame');

      final obj = malloc<ailia_tracker_dart.AILIATrackerObject>();
      status = ffi.ailiaTrackerGetObject(
        ppTracker.value,
        obj,
        0,
        ailia_tracker_dart.AILIA_TRACKER_OBJECT_VERSION,
      );
      expect(status, 0, reason: 'ailiaTrackerGetObject frame $frame');

      // The same object must keep the same tracking id across frames.
      trackedId ??= obj.ref.id;
      expect(obj.ref.id, trackedId, reason: 'consistent id in frame $frame');
      expect(obj.ref.category, 0);
      expect(obj.ref.w, greaterThan(0));
      expect(obj.ref.h, greaterThan(0));

      malloc.free(obj);
      malloc.free(count);
    }

    status = ffi.ailiaTrackerDestroy(ppTracker.value);
    expect(status, 0, reason: 'ailiaTrackerDestroy');
    malloc.free(ppTracker);
  });
}

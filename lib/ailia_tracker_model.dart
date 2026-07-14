// ailia Tracker Utility Class

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'ailia_tracker.dart' as ailia_tracker_dart;

/// Tracking target passed to [AiliaTrackerModel.addTarget].
/// Coordinates are normalized (1.0 means the image width / height).
class AiliaTrackerTarget {
  final int category;
  final double prob;
  final double x;
  final double y;
  final double w;
  final double h;

  AiliaTrackerTarget({
    required this.category,
    required this.prob,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

/// Tracking result returned from [AiliaTrackerModel.compute].
/// Coordinates are normalized (1.0 means the image width / height).
class AiliaTrackerObject {
  final int id;
  final int category;
  final double prob;
  final double x;
  final double y;
  final double w;
  final double h;

  AiliaTrackerObject({
    required this.id,
    required this.category,
    required this.prob,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

class AiliaTrackerModel {
  dynamic ailiaTracker;
  Pointer<Pointer<ailia_tracker_dart.AILIATracker>>? ppAiliaTracker;
  bool available = false;

  final int ailiaStatusSuccess = 0;
  final int ailiaDetectorObjectVersion = 1;

  static String ailiaCommonGetTrackerPath() {
    if (Platform.isAndroid || Platform.isLinux) {
      return 'libailia_tracker.so';
    }
    if (Platform.isMacOS) {
      return 'libailia_tracker.dylib';
    }
    if (Platform.isWindows) {
      return 'ailia_tracker.dll';
    }
    return 'internal';
  }

  static DynamicLibrary ailiaCommonGetLibrary(String path) {
    final DynamicLibrary library;
    if (Platform.isIOS) {
      library = DynamicLibrary.process();
    } else {
      library = DynamicLibrary.open(path);
    }
    return library;
  }

  /// Creates a tracker instance.
  ///
  /// [algorithm] is AILIA_TRACKER_ALGORITHM_*, [flags] is a logical OR of
  /// AILIA_TRACKER_FLAG_*. Settings default to the values documented in
  /// ailia_tracker.h and can be overridden individually.
  void create({
    int algorithm = ailia_tracker_dart.AILIA_TRACKER_ALGORITHM_BYTE_TRACK,
    int flags = ailia_tracker_dart.AILIA_TRACKER_FLAG_NONE,
    double scoreThreshold = 0.1,
    double nmsThreshold = 0.7,
    double trackThreshold = 0.5,
    int trackBuffer = 30,
    double matchThreshold = 0.8,
  }) {
    close(); // for reopen

    ailiaTracker = ailia_tracker_dart.ailiaTrackerFFI(
      ailiaCommonGetLibrary(ailiaCommonGetTrackerPath()),
    );
    ppAiliaTracker = malloc<Pointer<ailia_tracker_dart.AILIATracker>>();

    final Pointer<ailia_tracker_dart.AILIATrackerSettings> settings =
        malloc<ailia_tracker_dart.AILIATrackerSettings>();
    settings.ref.score_threshold = scoreThreshold;
    settings.ref.nms_threshold = nmsThreshold;
    settings.ref.track_threshold = trackThreshold;
    settings.ref.track_buffer = trackBuffer;
    settings.ref.match_threshold = matchThreshold;

    int status = ailiaTracker.ailiaTrackerCreate(
      ppAiliaTracker,
      algorithm,
      settings,
      ailia_tracker_dart.AILIA_TRACKER_SETTINGS_VERSION,
      flags,
    );

    malloc.free(settings);

    if (status != ailiaStatusSuccess) {
      throw Exception("ailiaTrackerCreate error $status");
    }

    available = true;
  }

  /// Registers one detection result of the current frame.
  void addTarget(AiliaTrackerTarget target) {
    if (!available) {
      throw Exception("Tracker not created");
    }

    final Pointer<ailia_tracker_dart.AILIADetectorObject> detectorObject =
        malloc<ailia_tracker_dart.AILIADetectorObject>();
    detectorObject.ref.category = target.category;
    detectorObject.ref.prob = target.prob;
    detectorObject.ref.x = target.x;
    detectorObject.ref.y = target.y;
    detectorObject.ref.w = target.w;
    detectorObject.ref.h = target.h;

    int status = ailiaTracker.ailiaTrackerAddTarget(
      ppAiliaTracker!.value,
      detectorObject,
      ailiaDetectorObjectVersion,
    );

    malloc.free(detectorObject);

    if (status != ailiaStatusSuccess) {
      throw Exception("ailiaTrackerAddTarget error $status");
    }
  }

  /// Performs tracking for the targets registered with [addTarget]
  /// and returns the tracked objects.
  List<AiliaTrackerObject> compute() {
    if (!available) {
      throw Exception("Tracker not created");
    }

    int status = ailiaTracker.ailiaTrackerCompute(ppAiliaTracker!.value);
    if (status != ailiaStatusSuccess) {
      throw Exception("ailiaTrackerCompute error $status");
    }

    final Pointer<UnsignedInt> count = malloc<UnsignedInt>();
    count.value = 0;
    status = ailiaTracker.ailiaTrackerGetObjectCount(
      ppAiliaTracker!.value,
      count,
    );
    if (status != ailiaStatusSuccess) {
      malloc.free(count);
      throw Exception("ailiaTrackerGetObjectCount error $status");
    }

    final List<AiliaTrackerObject> objects = [];
    final Pointer<ailia_tracker_dart.AILIATrackerObject> obj =
        malloc<ailia_tracker_dart.AILIATrackerObject>();
    for (int i = 0; i < count.value; i++) {
      status = ailiaTracker.ailiaTrackerGetObject(
        ppAiliaTracker!.value,
        obj,
        i,
        ailia_tracker_dart.AILIA_TRACKER_OBJECT_VERSION,
      );
      if (status != ailiaStatusSuccess) {
        malloc.free(obj);
        malloc.free(count);
        throw Exception("ailiaTrackerGetObject error $status");
      }
      objects.add(AiliaTrackerObject(
        id: obj.ref.id,
        category: obj.ref.category,
        prob: obj.ref.prob,
        x: obj.ref.x,
        y: obj.ref.y,
        w: obj.ref.w,
        h: obj.ref.h,
      ));
    }

    malloc.free(obj);
    malloc.free(count);

    return objects;
  }

  /// Returns the details of the last error.
  String getErrorDetail() {
    if (!available) {
      throw Exception("Tracker not created");
    }
    Pointer<Char> detail =
        ailiaTracker.ailiaTrackerGetErrorDetail(ppAiliaTracker!.value);
    return detail.cast<Utf8>().toDartString();
  }

  void close() {
    if (!available) {
      return;
    }

    Pointer<ailia_tracker_dart.AILIATracker> tracker = ppAiliaTracker!.value;
    ailiaTracker.ailiaTrackerDestroy(tracker);
    malloc.free(ppAiliaTracker!);

    available = false;
  }
}

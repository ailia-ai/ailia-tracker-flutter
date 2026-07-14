# ailia Tracker Flutter Package

!! CAUTION !!
“ailia” IS NOT OPEN SOURCE SOFTWARE (OSS).
As long as user complies with the conditions stated in [License Document](https://ailia.ai/license/), user may use the Software for free of charge, but the Software is basically paid software.

## About ailia Tracker

The ailia Tracker is a multi-object tracking library. By feeding the detection results of an object detector (such as YOLOX) into the tracker frame by frame, a consistent tracking ID is assigned to each object across frames. The tracker implements the ByteTrack algorithm.

## Usage

```dart
import 'package:ailia_tracker/ailia_tracker.dart';
import 'package:ailia_tracker/ailia_tracker_model.dart';

final tracker = AiliaTrackerModel();
tracker.create(); // ByteTrack with default settings

// Every frame: register the detection results, then compute
tracker.addTarget(AiliaTrackerTarget(
  category: 0, prob: 0.9, x: 0.1, y: 0.1, w: 0.2, h: 0.4,
));
final objects = tracker.compute();
for (final obj in objects) {
  print('id=${obj.id} category=${obj.category} prob=${obj.prob}');
}

tracker.close();
```

## API specification

https://github.com/axinc-ai/ailia-sdk

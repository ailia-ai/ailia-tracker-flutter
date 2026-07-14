import 'dart:async';

import 'package:flutter/material.dart';

import 'package:ailia_tracker/ailia_tracker_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ailiaTrackerModel = AiliaTrackerModel();
  Timer? _timer;
  int _frame = 0;
  List<AiliaTrackerObject> _objects = [];

  @override
  void initState() {
    super.initState();
    _ailiaTrackerModel.create();
    // Feed dummy detection results every 100ms and run tracking.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _trackOneFrame();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ailiaTrackerModel.close();
    super.dispose();
  }

  // Dummy detections: two objects moving on normalized coordinates (0 - 1).
  List<AiliaTrackerTarget> _dummyDetections(int frame) {
    final t = (frame % 100) / 100.0;
    return [
      // Object moving left to right at the top.
      AiliaTrackerTarget(
        category: 0,
        prob: 0.9,
        x: 0.1 + 0.6 * t,
        y: 0.1,
        w: 0.15,
        h: 0.3,
      ),
      // Object moving top to bottom on the left.
      AiliaTrackerTarget(
        category: 0,
        prob: 0.8,
        x: 0.1,
        y: 0.2 + 0.4 * t,
        w: 0.12,
        h: 0.25,
      ),
    ];
  }

  void _trackOneFrame() {
    for (final target in _dummyDetections(_frame)) {
      _ailiaTrackerModel.addTarget(target);
    }
    final objects = _ailiaTrackerModel.compute();
    setState(() {
      _frame++;
      _objects = objects;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lines = _objects
        .map((obj) => 'id=${obj.id} category=${obj.category} '
            'prob=${obj.prob.toStringAsFixed(2)} '
            'x=${obj.x.toStringAsFixed(2)} y=${obj.y.toStringAsFixed(2)} '
            'w=${obj.w.toStringAsFixed(2)} h=${obj.h.toStringAsFixed(2)}')
        .join('\n');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ailia Tracker example app'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Frame: $_frame\n$lines'),
            ),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _TrackerPainter(_objects),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerPainter extends CustomPainter {
  final List<AiliaTrackerObject> objects;

  _TrackerPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final obj in objects) {
      paint.color = Colors.primaries[obj.id % Colors.primaries.length];
      final rect = Rect.fromLTWH(
        obj.x * size.width,
        obj.y * size.height,
        obj.w * size.width,
        obj.h * size.height,
      );
      canvas.drawRect(rect, paint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'id=${obj.id}',
          style: TextStyle(color: paint.color, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, rect.topLeft + const Offset(2, -18));
    }
  }

  @override
  bool shouldRepaint(_TrackerPainter oldDelegate) =>
      oldDelegate.objects != objects;
}

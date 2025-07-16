import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:storysaz/models/media_element.dart';
import 'package:storysaz/models/story_element.dart';

class StoryVideoExporter {
  final Widget Function(Duration time) storyBuilder;
  final Duration duration;
  final int fps;

  StoryVideoExporter({
    required this.storyBuilder,
    required this.duration,
    this.fps = 30,
  });

  Future<List<String>> captureFrames() async {
    final frameCount = (duration.inMilliseconds / (1000 / fps)).ceil();
    final tempDir = await getTemporaryDirectory();
    final List<String> framePaths = [];
    final controller = ScreenshotController();

    try {
      for (int i = 0; i < frameCount; i++) {
        final time = Duration(milliseconds: (i * (1000 / fps)).round());
        final widget = storyBuilder(time);

        // Wrap the widget in a MaterialApp to ensure proper rendering
        final wrappedWidget = MaterialApp(
          home: Material(
            child: widget,
          ),
        );

        final image = await controller.captureFromWidget(
          wrappedWidget,
          delay: Duration(milliseconds: 100), // allow for video seek
          pixelRatio: 1.5,
        );

        final filePath =
            '${tempDir.path}/frame_${i.toString().padLeft(5, '0')}.png';
        final file = File(filePath);
        await file.writeAsBytes(image);
        framePaths.add(filePath);
      }
    } catch (e) {
      debugPrint('Error capturing frames: $e');
      // Clean up any partial frames
      for (var path in framePaths) {
        try {
          await File(path).delete();
        } catch (e) {
          debugPrint('Error deleting frame: $e');
        }
      }
      framePaths.clear();
    }

    return framePaths;
  }
}

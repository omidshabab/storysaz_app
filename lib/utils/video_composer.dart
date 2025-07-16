import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storysaz/models/story_element.dart';
import 'package:storysaz/models/media_element.dart';

class VideoComposer {
  final List<MediaElement> mediaElements;
  final List<TextElement> textElements;
  final Color backgroundColor;
  final Duration duration;

  VideoComposer({
    required this.mediaElements,
    required this.textElements,
    required this.backgroundColor,
    required this.duration,
  });

  Future<String> composeVideo() async {
    // Create a temporary directory for processing
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/story_export_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Initialize video controllers for all video elements
    final videoControllers = <VideoPlayerController>[];
    for (var element in mediaElements) {
      if (element.isVideo) {
        final controller = VideoPlayerController.file(File(element.path));
        await controller.initialize();
        videoControllers.add(controller);
      }
    }

    try {
      if (mediaElements.isEmpty) {
        throw Exception('No media elements found');
      }

      // For now, we'll use the first video as the base
      // In a production app, you would want to implement proper video composition
      final firstVideo = mediaElements.firstWhere((element) => element.isVideo);

      // Compress the video to reduce file size
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        firstVideo.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (mediaInfo?.file == null) {
        throw Exception('Failed to compress video');
      }

      // Copy the compressed video to our output path
      await mediaInfo!.file!.copy(outputPath);

      return outputPath;
    } finally {
      // Dispose all video controllers
      for (var controller in videoControllers) {
        await controller.dispose();
      }
    }
  }
}

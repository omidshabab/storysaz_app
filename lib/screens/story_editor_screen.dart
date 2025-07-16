import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:storysaz/widgets/icon_button.dart';
import 'package:uuid/uuid.dart';
import '../models/story_element.dart';
import '../widgets/draggable_text.dart';
import '../widgets/draggable_media.dart';
import '../models/media_element.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:indexed/indexed.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import 'package:storysaz/utils/video_composer.dart';
import 'package:storysaz/utils/story_video_exporter.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({super.key});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen>
    with SingleTickerProviderStateMixin {
  final List<TextElement> texts = [];
  final List<MediaElement> mediaElements = [];
  final screenshotController = ScreenshotController();
  TextElement? selectedText;
  MediaElement? selectedMedia;
  bool _isSolidColorBackground = false;
  Color _solidBackgroundColor = Colors.white;
  int _savedBackgroundColorValue = Colors.white.value;
  int _zIndexCounter = 0;

  IconData _saveIcon = Ionicons.cloud_download_outline;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    loadSavedStory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadSavedStory() async {
    final box = Hive.box<List<dynamic>>('stories');
    final settingsBox = Hive.box<int>('app_settings');

    // Clear existing elements to prevent duplicates or stale data
    texts.clear();
    mediaElements.clear();

    final savedStory = box.get('current_story');
    final savedMedia = box.get('current_media');
    final savedBgColor = settingsBox.get('background_color_value');

    if (savedStory != null) {
      setState(() {
        texts.addAll(savedStory.cast<TextElement>());
      });
    }
    if (savedMedia != null) {
      List<MediaElement> validMedia = [];
      for (var media in savedMedia.cast<MediaElement>()) {
        final file = File(media.path);
        if (await file.exists()) {
          validMedia.add(media);
        } else {
          debugPrint('Discarding missing media file from Hive: ${media.path}');
        }
      }
      setState(() {
        mediaElements.addAll(validMedia);
      });
    }
    if (savedBgColor != null) {
      setState(() {
        _solidBackgroundColor = Color(savedBgColor);
      });
    }

    // Initialize zIndexCounter to the maximum existing index
    int maxIndex = 0;
    for (var text in texts) {
      if (text.index > maxIndex) {
        maxIndex = text.index;
      }
    }
    for (var media in mediaElements) {
      if (media.index > maxIndex) {
        maxIndex = media.index;
      }
    }
    _zIndexCounter = maxIndex;
  }

  Future<void> saveStory() async {
    final box = Hive.box<List<dynamic>>('stories');
    final settingsBox = Hive.box<int>('app_settings');
    await box.put('current_story', texts);
    await box.put('current_media', mediaElements);
    await settingsBox.put(
        'background_color_value', _solidBackgroundColor.value);
  }

  void addNewText(double x, double y) {
    final newText = TextElement(
      id: const Uuid().v4(),
      x: x,
      y: y,
      text: "لورم ایپسوم ...",
      index: ++_zIndexCounter,
    );
    setState(() {
      texts.add(newText);
      selectedText = newText;
    });
    saveStory();
  }

  Future<void> exportStory() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    IconData tempIcon;

    try {
      // Check if story contains any videos
      bool hasVideos = mediaElements.any((element) => element.isVideo);

      if (hasVideos) {
        // Get the maximum video duration
        Duration maxDuration = Duration.zero;
        for (var element in mediaElements) {
          if (element.isVideo) {
            final videoController =
                VideoPlayerController.file(File(element.path));
            await videoController.initialize();
            if (videoController.value.duration > maxDuration) {
              maxDuration = videoController.value.duration;
            }
            await videoController.dispose();
          }
        }

        // Capture frames for the whole story
        final exporter = StoryVideoExporter(
          storyBuilder: (time) => buildStoryAtTime(time),
          duration: maxDuration,
          fps: 15, // Lower FPS for performance, adjust as needed
        );
        final framePaths = await exporter.captureFrames();

        // For iOS, we'll need to use a different approach since Process.run isn't supported
        // For now, we'll just save the first frame as an image
        if (framePaths.isNotEmpty) {
          final result = await ImageGallerySaver.saveFile(framePaths.first);

          if (mounted) {
            tempIcon = result['isSuccess']
                ? Ionicons.checkmark_outline
                : Ionicons.close_circle_outline;

            setState(() {
              _saveIcon = tempIcon;
            });

            await Future.delayed(const Duration(seconds: 3));

            if (mounted) {
              setState(() {
                _saveIcon = Ionicons.cloud_download_outline;
                _isSaving = false;
              });
            }
          }
        }
      } else {
        // Export as image if no videos
        final image = await screenshotController.capture();
        if (image != null) {
          final result = await ImageGallerySaver.saveImage(image);

          if (mounted) {
            tempIcon = result['isSuccess']
                ? Ionicons.checkmark_outline
                : Ionicons.close_circle_outline;

            setState(() {
              _saveIcon = tempIcon;
            });

            await Future.delayed(const Duration(seconds: 3));

            if (mounted) {
              setState(() {
                _saveIcon = Ionicons.cloud_download_outline;
                _isSaving = false;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error exporting story: $e');
      if (mounted) {
        tempIcon = Ionicons.close_circle_outline;
        setState(() {
          _saveIcon = tempIcon;
        });

        await Future.delayed(const Duration(seconds: 3));

        if (mounted) {
          setState(() {
            _saveIcon = Ionicons.cloud_download_outline;
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<void> _pickMedia() async {
    try {
      debugPrint('Starting media picker...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result == null) {
        debugPrint('No file selected');
        return;
      }

      final originalFile = File(result.files.single.path!);
      final isVideo = result.files.single.path!.toLowerCase().endsWith('.mp4');
      // debugPrint('Selected file: ${originalFile.path}, isVideo: $isVideo');

      // Get the application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(originalFile.path);
      final String localPath = p.join(appDocDir.path, fileName);
      final File newFile = await originalFile.copy(localPath);

      debugPrint('Copied file to: ${newFile.path}');
      debugPrint('Copied file exists: ${await newFile.exists()}');

      double mediaWidth = 200;
      double mediaHeight = 200;

      if (!isVideo) {
        final Image image = Image.file(newFile);
        final Completer<ImageInfo> completer = Completer<ImageInfo>();
        image.image
            .resolve(const ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info);
        }));
        ImageInfo imageInfo = await completer.future;
        mediaWidth = imageInfo.image.width.toDouble();
        mediaHeight = imageInfo.image.height.toDouble();

        // Normalize dimensions to fit within a reasonable editor size, e.g., max width of 300
        if (mediaWidth > 300) {
          mediaHeight = (mediaHeight / mediaWidth) * 300;
          mediaWidth = 300;
        }
      } else {
        // For videos, set a default width and calculate height for 16:9 aspect ratio
        mediaWidth = 300;
        mediaHeight =
            mediaWidth * (9 / 16); // Assuming 16:9 aspect ratio for videos
      }

      final newMedia = MediaElement(
        id: const Uuid().v4(),
        path: newFile.path, // Use the path to the copied file
        x: 100,
        y: 100,
        width: mediaWidth,
        height: mediaHeight,
        isVideo: isVideo,
        index: ++_zIndexCounter,
      );

      setState(() {
        mediaElements.add(newMedia);
        selectedMedia = newMedia;
        selectedText = null;
      });
      saveStory();
      debugPrint('Media added successfully');
      debugPrint('Media path saved to Hive: ${newMedia.path}');
    } catch (e) {
      debugPrint('Error in _pickMedia: $e');
    }
  }

  /// Builds the story as a widget at a specific time (for video export)
  Widget buildStoryAtTime(Duration time) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        color: _solidBackgroundColor,
      ),
      child: Indexer(
        children: [
          ...texts.map((textElement) {
            return Indexed(
              index: textElement.index,
              child: DraggableText(
                key: ValueKey(textElement.id),
                textElement: textElement,
                isSelected: false,
                onSelected: (_) {},
                onChanged: (_) {},
                onDelete: () {},
                displayColor: _solidBackgroundColor == const Color(0xFF18181B)
                    ? Colors.white
                    : Colors.black87,
                parentBackgroundColor: _solidBackgroundColor,
              ),
            );
          }),
          ...mediaElements.map((mediaElement) {
            return Indexed(
              index: mediaElement.index,
              child: mediaElement.isVideo
                  ? FutureBuilder<Widget>(
                      future: _buildVideoFrame(mediaElement, time),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return SizedBox(
                            width: mediaElement.width,
                            height: mediaElement.height,
                            child: Container(color: Colors.black12),
                          );
                        }
                      },
                    )
                  : DraggableMedia(
                      key: ValueKey(mediaElement.id),
                      mediaElement: mediaElement,
                      isSelected: false,
                      onSelected: (_) {},
                      onChanged: (_) {},
                      onDelete: () {},
                      displayColor:
                          _solidBackgroundColor == const Color(0xFF18181B)
                              ? Colors.white
                              : Colors.black87,
                      parentBackgroundColor: _solidBackgroundColor,
                    ),
            );
          }),
        ],
      ),
    );
  }

  /// Helper to build a video frame widget at a specific time
  Future<Widget> _buildVideoFrame(
      MediaElement mediaElement, Duration time) async {
    final controller = VideoPlayerController.file(File(mediaElement.path));
    try {
      await controller.initialize();
      await controller.seekTo(time);
      final widget = SizedBox(
        width: mediaElement.width,
        height: mediaElement.height,
        child: VideoPlayer(controller),
      );
      await Future.delayed(
          const Duration(milliseconds: 50)); // let frame render
      return widget;
    } finally {
      await controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: 1080,
                height: 1920,
                decoration: BoxDecoration(
                  color: _solidBackgroundColor,
                ),
                child: Indexer(
                  children: [
                    ...texts.map((textElement) {
                      return Indexed(
                        index: textElement.index,
                        child: DraggableText(
                          key: ValueKey(textElement.id),
                          textElement: textElement,
                          isSelected: selectedText?.id == textElement.id,
                          onSelected: (textElement) {
                            setState(() {
                              selectedText = textElement;
                              selectedMedia = null;
                              final int textIndex = texts
                                  .indexWhere((t) => t.id == textElement.id);
                              if (textIndex != -1) {
                                texts[textIndex].index = ++_zIndexCounter;
                              }
                              debugPrint(
                                  'Text selected: ${textElement.id}, new index: ${textElement.index}');
                            });
                          },
                          onChanged: (text) {
                            setState(() {
                              final index =
                                  texts.indexWhere((t) => t.id == text.id);
                              if (index != -1) {
                                texts[index] = text;
                              }
                              // debugPrint(
                              //     'Text changed: ${text.id}, new index: ${text.index}');
                            });
                            saveStory();
                          },
                          onDelete: () {
                            setState(() {
                              texts.removeWhere((t) => t.id == textElement.id);
                              if (selectedText?.id == textElement.id) {
                                selectedText = null;
                              }
                            });
                            saveStory();
                          },
                          displayColor:
                              _solidBackgroundColor == const Color(0xFF18181B)
                                  ? Colors.white
                                  : Colors.black87,
                          parentBackgroundColor: _solidBackgroundColor,
                        ),
                      );
                    }),
                    ...mediaElements.map((mediaElement) {
                      return Indexed(
                        index: mediaElement.index,
                        child: DraggableMedia(
                          key: ValueKey(mediaElement.id),
                          mediaElement: mediaElement,
                          isSelected: selectedMedia?.id == mediaElement.id,
                          onSelected: (mediaElement) {
                            setState(() {
                              selectedMedia = mediaElement;
                              selectedText = null;
                              final int mediaIndex = mediaElements
                                  .indexWhere((m) => m.id == mediaElement.id);
                              if (mediaIndex != -1) {
                                mediaElements[mediaIndex].index =
                                    ++_zIndexCounter;
                              }
                              debugPrint(
                                  'Media selected: ${mediaElement.id}, new index: ${mediaElement.index}');
                            });
                          },
                          onChanged: (media) {
                            setState(() {
                              final index = mediaElements
                                  .indexWhere((m) => m.id == media.id);
                              if (index != -1) {
                                mediaElements[index] = media;
                              }
                              // debugPrint(
                              //     'Media changed: ${media.id}, new index: ${media.index}');
                            });
                            saveStory();
                          },
                          onDelete: () {
                            setState(() {
                              mediaElements
                                  .removeWhere((m) => m.id == mediaElement.id);
                              if (selectedMedia?.id == mediaElement.id) {
                                selectedMedia = null;
                              }
                            });
                            saveStory();
                          },
                          displayColor:
                              _solidBackgroundColor == const Color(0xFF18181B)
                                  ? Colors.white
                                  : Colors.black87,
                          parentBackgroundColor: _solidBackgroundColor,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "استوری ساز",
                      style: TextStyle(
                        fontSize: 25,
                        color: _solidBackgroundColor == const Color(0xFF18181B)
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                width: screen.width,
                height: screen.height,
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: AppIconButton(
                        key: ValueKey(_saveIcon),
                        icon: _saveIcon,
                        onPressed: exportStory,
                        color: _solidBackgroundColor == const Color(0xFF18181B)
                            ? Colors.white
                            : Colors.black87,
                        borderColor:
                            _solidBackgroundColor == const Color(0xFF18181B)
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    SizedBox(width: 10),
                    AppIconButton(
                      icon: Ionicons.folder_open_outline,
                      onPressed: () {
                        debugPrint('Media picker button pressed');
                        _pickMedia();
                      },
                      color: _solidBackgroundColor == const Color(0xFF18181B)
                          ? Colors.white
                          : Colors.black87,
                      borderColor:
                          _solidBackgroundColor == const Color(0xFF18181B)
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                    ),
                    SizedBox(width: 10),
                    AppIconButton(
                      icon: Ionicons.text_outline,
                      onPressed: () {
                        addNewText(
                          screen.width / 3,
                          screen.height / 2,
                        );
                      },
                      color: _solidBackgroundColor == const Color(0xFF18181B)
                          ? Colors.white
                          : Colors.black87,
                      borderColor:
                          _solidBackgroundColor == const Color(0xFF18181B)
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                    ),
                    SizedBox(width: 10),
                    AppIconButton(
                      icon: Ionicons.filter_circle_outline,
                      onPressed: () {
                        setState(() {
                          _solidBackgroundColor =
                              _solidBackgroundColor == const Color(0xFF18181B)
                                  ? Colors.white
                                  : const Color(0xFF18181B);
                        });
                        saveStory();
                      },
                      color: _solidBackgroundColor == const Color(0xFF18181B)
                          ? Colors.white
                          : Colors.black87,
                      borderColor:
                          _solidBackgroundColor == const Color(0xFF18181B)
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

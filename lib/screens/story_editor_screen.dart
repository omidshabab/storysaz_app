import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:storysaz/widgets/icon_button.dart';
import 'package:uuid/uuid.dart';
import '../models/story_element.dart';
import '../widgets/draggable_text.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({super.key});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen>
    with SingleTickerProviderStateMixin {
  final List<TextElement> texts = [];
  final screenshotController = ScreenshotController();
  TextElement? selectedText;
  bool _isSolidColorBackground = false;
  Color _solidBackgroundColor = Colors.white;
  int _savedBackgroundColorValue = Colors.white.value;

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
    final savedStory = box.get('current_story');
    final savedBgColor = settingsBox.get('background_color_value');

    if (savedStory != null) {
      setState(() {
        texts.addAll(savedStory.cast<TextElement>());
      });
    }
    if (savedBgColor != null) {
      setState(() {
        _solidBackgroundColor = Color(savedBgColor);
      });
    }
  }

  Future<void> saveStory() async {
    final box = Hive.box<List<dynamic>>('stories');
    final settingsBox = Hive.box<int>('app_settings');
    await box.put('current_story', texts);
    await settingsBox.put(
        'background_color_value', _solidBackgroundColor.value);
  }

  void addNewText(double x, double y) {
    final newText = TextElement(
      id: const Uuid().v4(),
      x: x,
      y: y,
      text: "لورم ایپسوم ...",
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

    IconData tempIcon; // Temporarily hold the icon for success/failure

    try {
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
    } catch (e) {
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
                child: Stack(
                  children: texts.map((textElement) {
                    return DraggableText(
                      key: ValueKey(textElement.id),
                      textElement: textElement,
                      isSelected: selectedText?.id == textElement.id,
                      onSelected: (text) {
                        setState(() => selectedText = text);
                      },
                      onChanged: (text) {
                        setState(() {
                          final index =
                              texts.indexWhere((t) => t.id == text.id);
                          texts[index] = text;
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
                    );
                  }).toList(),
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

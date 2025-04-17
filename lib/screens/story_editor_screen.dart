import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:storysaz/widgets/icon_button.dart';
import 'package:uuid/uuid.dart';
import '../models/story_element.dart';
import '../widgets/draggable_text.dart';
import '../widgets/text_editing_controls.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({super.key});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final List<TextElement> texts = [];
  String selectedBackground = 'assets/backgrounds/bg1.png';
  final screenshotController = ScreenshotController();
  TextElement? selectedText;
  final backgrounds = [
    'assets/backgrounds/bg1.png',
    'assets/backgrounds/bg2.png',
    'assets/backgrounds/bg3.png',
  ];

  @override
  void initState() {
    super.initState();
    loadSavedStory();
  }

  Future<void> loadSavedStory() async {
    final box = Hive.box<List<dynamic>>('stories');
    final savedStory = box.get('current_story');
    if (savedStory != null) {
      setState(() {
        texts.addAll(savedStory.cast<TextElement>());
      });
    }
  }

  Future<void> saveStory() async {
    final box = Hive.box<List<dynamic>>('stories');
    await box.put('current_story', texts);
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
    final image = await screenshotController.capture();
    if (image != null) {
      await ImageGallerySaver.saveImage(image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story saved to gallery')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     "استوری ساز",
        //     style: TextStyle(
        //       fontSize: 25,
        //       fontWeight: FontWeight.w600,
        //       letterSpacing: -1,
        //       color: Color(0xff3B3B3B),
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.add),
        //       onPressed: _addNewText,
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.save),
        //       onPressed: _exportStory,
        //     ),
        //   ],
        // ),

        body: Stack(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: 1080,
                height: 1920,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(selectedBackground),
                    fit: BoxFit.cover,
                  ),
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
                    );
                  }).toList(),
                ),
              ),
            ),

            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                    // color: Colors.black,
                    ),
                padding: EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // AppIconButton(
                    //   icon: Ionicons.text_outline,
                    //   onPressed: () {
                    //     addNewText(
                    //       screen.width / 3,
                    //       screen.height / 2,
                    //     );
                    //   },
                    // ),

                    Text(
                      "استوری ساز",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    )
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Container(
                width: screen.width,
                height: screen.height,
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppIconButton(
                      icon: Ionicons.text_outline,
                      onPressed: () {
                        addNewText(
                          screen.width / 3,
                          screen.height / 2,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // if (_selectedText != null)
            //   Positioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     child: TextEditingControls(
            //       textElement: _selectedText!,
            //       onChanged: (text) {
            //         setState(() {
            //           final index = _texts.indexWhere((t) => t.id == text.id);
            //           _texts[index] = text;
            //         });
            //         _saveStory();
            //       },
            //     ),
            //   ),
          ],
        ),
        // bottomSheet: Container(
        //   height: 100,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: _backgrounds.length,
        //     itemBuilder: (context, index) {
        //       return GestureDetector(
        //         onTap: () {
        //           setState(() {
        //             _selectedBackground = _backgrounds[index];
        //           });
        //         },
        //         child: Container(
        //           width: 80,
        //           margin: const EdgeInsets.all(8),
        //           decoration: BoxDecoration(
        //             border: Border.all(
        //               color: _selectedBackground == _backgrounds[index]
        //                   ? Colors.blue
        //                   : Colors.transparent,
        //               width: 2,
        //             ),
        //             image: DecorationImage(
        //               image: AssetImage(_backgrounds[index]),
        //               fit: BoxFit.cover,
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }
}

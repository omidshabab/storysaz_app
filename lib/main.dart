import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storysaz/models/color_adapter.dart';
import 'package:storysaz/models/story_element.dart';
import 'package:storysaz/screens/story_editor_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(StoryElementAdapter());
  Hive.registerAdapter(TextElementAdapter());
  Hive.registerAdapter(ColorAdapter());

  await Hive.openBox<List<dynamic>>('stories');

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Estedad",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StoryEditorScreen(),
    );
  }
}

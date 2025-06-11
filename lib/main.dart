import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storysaz/models/color_adapter.dart';
import 'package:storysaz/models/story_element.dart';
import 'package:storysaz/screens/story_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(StoryElementAdapter());
  Hive.registerAdapter(TextElementAdapter());
  Hive.registerAdapter(ColorAdapter());

  await Hive.openBox<List<dynamic>>('stories');
  await Hive.openBox<int>('app_settings');

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
      locale: const Locale('fa', 'IR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'),
      ],
      theme: ThemeData(
        fontFamily: "Estedad",
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color.fromARGB((255 * 0.1).round(), 0, 0, 0),
          cursorColor: Colors.black,
          selectionHandleColor: Colors.black,
        ),
      ),
      home: const StoryEditorScreen(),
    );
  }
}

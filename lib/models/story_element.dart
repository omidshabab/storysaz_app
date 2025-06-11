import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'story_element.g.dart';

@HiveType(typeId: 0)
class StoryElement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double x;

  @HiveField(2)
  double y;

  @HiveField(3)
  double rotation;

  @HiveField(4)
  double scale;

  StoryElement({
    required this.id,
    required this.x,
    required this.y,
    this.rotation = 0.0,
    this.scale = 1.0,
  });
}

@HiveType(typeId: 1)
class TextElement extends StoryElement {
  @HiveField(5)
  String text;

  @HiveField(6)
  double fontSize;

  @HiveField(7)
  int colorValue; // Changed from Color to int

  @HiveField(8)
  bool hasBackground; // New field for text background

  Color get color => Color(colorValue); // Getter for color

  TextElement({
    required String id,
    required double x,
    required double y,
    required this.text,
    this.fontSize = 35.0,
    Color color = Colors.black, // Accept Color in constructor
    double rotation = 0.0,
    double scale = 1.0,
    this.hasBackground = false, // Initialize new field
  })  : this.colorValue =
            color.value, // Store color value instead of Color object
        super(id: id, x: x, y: y, rotation: rotation, scale: scale);
}

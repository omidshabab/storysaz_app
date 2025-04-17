import 'package:flutter/material.dart';
import '../models/story_element.dart';

class TextEditingControls extends StatelessWidget {
  final TextElement textElement;
  final Function(TextElement) onChanged;

  const TextEditingControls({
    super.key,
    required this.textElement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: textElement.text),
            onChanged: (value) {
              onChanged(TextElement(
                id: textElement.id,
                x: textElement.x,
                y: textElement.y,
                text: value,
                fontSize: textElement.fontSize,
                color: textElement.color,
                rotation: textElement.rotation,
                scale: textElement.scale,
              ));
            },
            decoration: const InputDecoration(
              labelText: 'Text',
            ),
          ),
          Slider(
            value: textElement.fontSize,
            min: 10,
            max: 100,
            onChanged: (value) {
              onChanged(TextElement(
                id: textElement.id,
                x: textElement.x,
                y: textElement.y,
                text: textElement.text,
                fontSize: value,
                color: textElement.color,
                rotation: textElement.rotation,
                scale: textElement.scale,
              ));
            },
          ),
        ],
      ),
    );
  }
}

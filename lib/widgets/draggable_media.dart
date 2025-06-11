import 'package:flutter/material.dart';
import 'package:storysaz/models/media_element.dart';
import 'dart:io';

class DraggableMedia extends StatefulWidget {
  final MediaElement mediaElement;
  final bool isSelected;
  final Function(MediaElement) onChanged;
  final Function() onDelete;
  final Function(MediaElement) onSelected;

  const DraggableMedia({
    Key? key,
    required this.mediaElement,
    required this.isSelected,
    required this.onChanged,
    required this.onDelete,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<DraggableMedia> createState() => _DraggableMediaState();
}

class _DraggableMediaState extends State<DraggableMedia> {
  late double x;
  late double y;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    x = widget.mediaElement.x;
    y = widget.mediaElement.y;
    width = widget.mediaElement.width;
    height = widget.mediaElement.height;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.mediaElement),
        onPanUpdate: (details) {
          setState(() {
            x += details.delta.dx;
            y += details.delta.dy;
          });
          widget.onChanged(
            MediaElement(
              id: widget.mediaElement.id,
              path: widget.mediaElement.path,
              x: x,
              y: y,
              width: width,
              height: height,
              isVideo: widget.mediaElement.isVideo,
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: widget.isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
              child: widget.mediaElement.isVideo
                  ? const Icon(Icons.play_circle_outline, size: 50)
                  : Image.file(
                      File(widget.mediaElement.path),
                      fit: BoxFit.cover,
                    ),
            ),
            if (widget.isSelected)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ionicons/ionicons.dart';
import 'package:storysaz/widgets/icon_button.dart';
import '../models/story_element.dart';

class DraggableText extends StatefulWidget {
  final TextElement textElement;
  final bool isSelected;
  final Function(TextElement) onSelected;
  final Function(TextElement) onChanged;
  final VoidCallback onDelete;

  const DraggableText({
    required Key key,
    required this.textElement,
    required this.isSelected,
    required this.onSelected,
    required this.onChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  late double _scale;
  late double _rotation;
  late double _posX;
  late double _posY;

  @override
  void initState() {
    super.initState();
    _scale = widget.textElement.scale;
    _rotation = widget.textElement.rotation;
    _posX = widget.textElement.x;
    _posY = widget.textElement.y;
  }

  void _updateElement() {
    final updatedElement = TextElement(
      id: widget.textElement.id,
      x: _posX,
      y: _posY,
      text: widget.textElement.text,
      fontSize: widget.textElement.fontSize,
      color: widget.textElement.color,
      rotation: _rotation,
      scale: _scale,
    );
    widget.onChanged(updatedElement);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _posX,
      top: _posY,
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.textElement),
        onScaleStart: (details) {
          widget.onSelected(widget.textElement);
        },
        onScaleUpdate: (details) {
          setState(() {
            if (details.scale != 1.0) {
              _scale = widget.textElement.scale * details.scale;
            }
            if (details.rotation != 0.0) {
              _rotation = widget.textElement.rotation + details.rotation;
            }
            _posX += details.focalPointDelta.dx;
            _posY += details.focalPointDelta.dy;
          });
        },
        onScaleEnd: (_) => _updateElement(),
        child: Transform.scale(
          scale: _scale,
          child: Transform.rotate(
            angle: _rotation,
            child: Container(
              // decoration: widget.isSelected
              //     ? BoxDecoration(
              //         border: Border.all(color: Colors.blue),
              //       )
              //     : null,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      showGeneralDialog(
                        barrierDismissible: false,
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return StatefulBuilder(
                            builder: (context, setState) => GestureDetector(
                              onTap: () {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  color: Colors.white.withOpacity(0.4),
                                  child: SafeArea(
                                    child: Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Padding(
                                        padding: EdgeInsets.only(bottom: 25),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(25),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        AppIconButton(
                                                          icon: Ionicons
                                                              .close_outline,
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        SizedBox(width: 10),
                                                        AppIconButton(
                                                          icon: IconlyLight
                                                              .delete,
                                                          onPressed: () {
                                                            widget.onDelete();

                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: TextField(
                                                          // controller:
                                                          // textEditingController,
                                                          textAlign:
                                                              TextAlign.center,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          cursorColor:
                                                              Colors.black,
                                                          minLines: 1,
                                                          maxLines: 10,
                                                          maxLength: 150,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff3B3B3B),
                                                            fontSize: 35,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: -2.5,
                                                          ),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "تغییر متن",
                                                            // hintStyle: TextStyle(
                                                            // fontFamily:
                                                            //     selectedFont
                                                            //         .fontFamily,
                                                            // fontSize:
                                                            //     _currentFontSizeSliderValue,
                                                            // fontWeight:
                                                            //     toFontWeightConverter(
                                                            //         _currentFontWeightSliderValue),
                                                            // height:
                                                            //     _currentLineHeightSliderValue),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.textElement.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.5,
                        fontSize: widget.textElement.fontSize,
                        color: Color(0xff3B3B3B),
                        // color: widget.textElement.color,
                      ),
                    ),
                  )
                  // if (widget.isSelected)
                  //   Positioned(
                  //     right: -20,
                  //     top: -20,
                  //     child: IconButton(
                  //       icon: const Icon(Icons.close),
                  //       onPressed: widget.onDelete,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

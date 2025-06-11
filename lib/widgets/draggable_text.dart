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
  final Color displayColor;
  final Color parentBackgroundColor;

  const DraggableText({
    required Key key,
    required this.textElement,
    required this.isSelected,
    required this.onSelected,
    required this.onChanged,
    required this.onDelete,
    required this.displayColor,
    required this.parentBackgroundColor,
  }) : super(key: key);

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late double _rotation;
  late double _posX;
  late double _posY;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _scale = widget.textElement.scale;
    _rotation = widget.textElement.rotation;
    _posX = widget.textElement.x;
    _posY = widget.textElement.y;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(_animationController);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      hasBackground: widget.textElement.hasBackground,
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
          _animationController.forward();
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
        onScaleEnd: (_) {
          _updateElement();
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: widget.textElement.hasBackground
                      ? BoxDecoration(
                          color: widget.parentBackgroundColor ==
                                  const Color(0xFF18181B)
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xFF18181B).withOpacity(0.05),
                          borderRadius: BorderRadius.zero,
                        )
                      : null,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _animationController.forward();
                          showGeneralDialog(
                            barrierDismissible: false,
                            context: context,
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              final TextEditingController
                                  textEditingController = TextEditingController(
                                      text: widget.textElement.text);
                              bool hasTextBackgroundLocal =
                                  widget.textElement.hasBackground;
                              return StatefulBuilder(
                                builder: (context, setStateLocal) =>
                                    GestureDetector(
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: Container(
                                      color: widget.parentBackgroundColor ==
                                              const Color(0xFF18181B)
                                          ? const Color(0xFF18181B)
                                              .withOpacity(0.9)
                                          : Colors.white.withOpacity(0.4),
                                      child: SafeArea(
                                        child: Scaffold(
                                          backgroundColor: Colors.transparent,
                                          body: Expanded(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 25),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(25),
                                                    child: Row(
                                                      children: [
                                                        AppIconButton(
                                                          icon: Ionicons
                                                              .close_outline,
                                                          onPressed: () {
                                                            _animationController
                                                                .reverse();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          color: widget
                                                              .displayColor,
                                                          borderColor: widget
                                                                      .parentBackgroundColor ==
                                                                  const Color(
                                                                      0xFF18181B)
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.1),
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
                                                          color: widget
                                                              .displayColor,
                                                          borderColor: widget
                                                                      .parentBackgroundColor ==
                                                                  const Color(
                                                                      0xFF18181B)
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.1),
                                                        ),
                                                        SizedBox(width: 10),
                                                        AppIconButton(
                                                          icon: Ionicons
                                                              .square_outline,
                                                          onPressed: () {
                                                            setStateLocal(() {
                                                              hasTextBackgroundLocal =
                                                                  !hasTextBackgroundLocal;
                                                            });
                                                          },
                                                          color: widget
                                                              .displayColor,
                                                          borderColor: widget
                                                                      .parentBackgroundColor ==
                                                                  const Color(
                                                                      0xFF18181B)
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.1),
                                                        ),
                                                        SizedBox(width: 10),
                                                        AppIconButton(
                                                          icon: Ionicons
                                                              .checkmark_outline,
                                                          onPressed: () {
                                                            final updatedTextElement =
                                                                TextElement(
                                                              id: widget
                                                                  .textElement
                                                                  .id,
                                                              x: widget
                                                                  .textElement
                                                                  .x,
                                                              y: widget
                                                                  .textElement
                                                                  .y,
                                                              text:
                                                                  textEditingController
                                                                      .text,
                                                              fontSize: widget
                                                                  .textElement
                                                                  .fontSize,
                                                              color: widget
                                                                  .textElement
                                                                  .color,
                                                              rotation: widget
                                                                  .textElement
                                                                  .rotation,
                                                              scale: widget
                                                                  .textElement
                                                                  .scale,
                                                              hasBackground:
                                                                  hasTextBackgroundLocal,
                                                            );
                                                            widget.onChanged(
                                                                updatedTextElement);
                                                            _animationController
                                                                .reverse();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          color: widget
                                                              .displayColor,
                                                          borderColor: widget
                                                                      .parentBackgroundColor ==
                                                                  const Color(
                                                                      0xFF18181B)
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.1),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              hasTextBackgroundLocal
                                                                  ? BoxDecoration(
                                                                      color: widget.parentBackgroundColor ==
                                                                              const Color(
                                                                                  0xFF18181B)
                                                                          ? Colors
                                                                              .white
                                                                              .withOpacity(0.05)
                                                                          : const Color(0xFF18181B).withOpacity(0.05),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                    )
                                                                  : null,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          child: IntrinsicWidth(
                                                            child:
                                                                IntrinsicHeight(
                                                              child: TextField(
                                                                controller:
                                                                    textEditingController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                textAlignVertical:
                                                                    TextAlignVertical
                                                                        .center,
                                                                cursorColor: widget
                                                                    .displayColor,
                                                                minLines: 1,
                                                                maxLines: 10,
                                                                style:
                                                                    TextStyle(
                                                                  color: widget
                                                                      .displayColor,
                                                                  fontSize: 35,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      -2.5,
                                                                ),
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      "تغییر متن",
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  isDense: true,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                ),
                              );
                            },
                          ).whenComplete(() => _animationController.reverse());
                        },
                        child: Container(
                          decoration: widget.textElement.hasBackground
                              ? BoxDecoration(
                                  color: widget.parentBackgroundColor ==
                                          const Color(0xFF18181B)
                                      ? Colors.white.withOpacity(0.05)
                                      : const Color(0xFF18181B)
                                          .withOpacity(0.05),
                                  borderRadius: BorderRadius.zero,
                                )
                              : null,
                          padding: EdgeInsets.zero,
                          child: Text(
                            widget.textElement.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1.5,
                              fontSize: widget.textElement.fontSize,
                              color: widget.displayColor,
                              // color: widget.textElement.color,
                            ),
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
            );
          },
        ),
      ),
    );
  }
}

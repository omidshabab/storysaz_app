import 'package:flutter/material.dart';
import 'package:storysaz/models/media_element.dart';
import 'package:storysaz/widgets/icon_button.dart';
import 'package:ionicons/ionicons.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';
import 'dart:ui';

class DraggableMedia extends StatefulWidget {
  final MediaElement mediaElement;
  final bool isSelected;
  final Function(MediaElement) onChanged;
  final Function() onDelete;
  final Function(MediaElement) onSelected;
  final Color displayColor;
  final Color parentBackgroundColor;

  const DraggableMedia({
    Key? key,
    required this.mediaElement,
    required this.isSelected,
    required this.onChanged,
    required this.onDelete,
    required this.onSelected,
    required this.displayColor,
    required this.parentBackgroundColor,
  }) : super(key: key);

  @override
  State<DraggableMedia> createState() => _DraggableMediaState();
}

class _DraggableMediaState extends State<DraggableMedia>
    with SingleTickerProviderStateMixin {
  late double x;
  late double y;
  late double width;
  late double height;
  late double _scale = 1.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    x = widget.mediaElement.x;
    y = widget.mediaElement.y;
    width = widget.mediaElement.width;
    height = widget.mediaElement.height;
    _scale = widget.mediaElement.scale;

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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          widget.onSelected(widget.mediaElement);
          _animationController.forward();
          showGeneralDialog(
            barrierDismissible: false,
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return StatefulBuilder(
                builder: (context, setStateLocal) => GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: widget.parentBackgroundColor ==
                              const Color(0xFF18181B)
                          ? const Color(0xFF18181B).withOpacity(0.9)
                          : Colors.white.withOpacity(0.4),
                      child: SafeArea(
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(25),
                                child: Row(
                                  children: [
                                    AppIconButton(
                                      icon: Ionicons.close_outline,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      color: widget.displayColor,
                                      borderColor:
                                          widget.parentBackgroundColor ==
                                                  const Color(0xFF18181B)
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.1),
                                    ),
                                    const SizedBox(width: 10),
                                    AppIconButton(
                                      icon: IconlyLight.delete,
                                      onPressed: () {
                                        widget.onDelete();
                                        Navigator.pop(context);
                                      },
                                      color: widget.displayColor,
                                      borderColor:
                                          widget.parentBackgroundColor ==
                                                  const Color(0xFF18181B)
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 35.0),
                                    child: widget.mediaElement.isVideo
                                        ? const Icon(Icons.play_circle_outline,
                                            size: 100)
                                        : Image.file(
                                            File(widget.mediaElement.path),
                                            fit: BoxFit.contain,
                                          ),
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
              );
            },
          ).whenComplete(() {
            if (mounted) {
              _animationController.reverse();
            }
          });
        },
        onScaleStart: (details) {
          widget.onSelected(widget.mediaElement);
          _animationController.forward();
        },
        onScaleUpdate: (details) {
          setState(() {
            if (details.scale != 1.0) {
              _scale =
                  (widget.mediaElement.scale * details.scale).clamp(0.5, 3.0);
            }
            x += details.focalPointDelta.dx;
            y += details.focalPointDelta.dy;
          });
        },
        onScaleEnd: (_) {
          widget.onChanged(
            MediaElement(
              id: widget.mediaElement.id,
              path: widget.mediaElement.path,
              x: x,
              y: y,
              width: width,
              height: height,
              isVideo: widget.mediaElement.isVideo,
              index: widget.mediaElement.index,
              scale: _scale.clamp(0.5, 3.0),
            ),
          );
          if (mounted) {
            _animationController.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value * _scale,
                child: Container(
                  width: width,
                  height: height,
                  child: widget.mediaElement.isVideo
                      ? const Icon(Icons.play_circle_outline, size: 50)
                      : Image.file(
                          File(widget.mediaElement.path),
                          fit: BoxFit.cover,
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

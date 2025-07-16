import 'package:flutter/material.dart';
import 'package:storysaz/models/media_element.dart';
import 'package:storysaz/widgets/icon_button.dart';
import 'package:ionicons/ionicons.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';
import 'dart:ui';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

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

    if (widget.mediaElement.isVideo) {
      // Add a small delay before initializing video
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _initializeVideo();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant DraggableMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaElement.path != widget.mediaElement.path) {
      if (widget.mediaElement.isVideo) {
        _videoController?.dispose(); // Dispose old controller if path changes
        _initializeVideo();
      } else if (!widget.mediaElement.isVideo && _videoController != null) {
        _videoController
            ?.dispose(); // Dispose video controller if it's no longer a video
        _videoController = null;
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;

    try {
      final file = File(widget.mediaElement.path);

      _videoController = VideoPlayerController.file(file);

      // Add listener before initialization
      _videoController!.addListener(() {
        if (_videoController!.value.hasError) {
          debugPrint(
              'Video player error for file ${widget.mediaElement.path}: ${_videoController!.value.errorDescription}');
          if (mounted) {
            setState(() {
              _isVideoError = true;
            });
          }
        }
      });

      await _videoController!.initialize();

      if (!mounted) return;

      if (_videoController!.value.isInitialized) {
        // Update dimensions based on video's natural aspect ratio
        final videoAspectRatio = _videoController!.value.aspectRatio;
        if (videoAspectRatio > 0) {
          final newWidth = widget.mediaElement.width;
          final newHeight = newWidth / videoAspectRatio;

          if (mounted) {
            setState(() {
              width = newWidth;
              height = newHeight;
            });
          }
        }

        _videoController!.setLooping(true);
        _videoController!.play();
        setState(() {
          _isVideoInitialized = true;
        });
        debugPrint(
            'Video initialized successfully for file: ${widget.mediaElement.path}');
      } else {
        debugPrint(
            'Video initialization failed for file ${widget.mediaElement.path}: Not initialized after calling initialize().');
        setState(() {
          _isVideoError = true;
        });
      }
    } catch (e) {
      debugPrint(
          'Error initializing video for file ${widget.mediaElement.path}: $e');
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _videoController?.pause();
      _videoController?.removeListener(() {});
      _videoController?.dispose();
    } catch (e) {
      debugPrint('Error disposing video controller: $e');
    }
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    final File videoFile = File(widget.mediaElement.path);
    if (!videoFile.existsSync()) {
      debugPrint(
          'Synchronous check: Video file not found at path: ${widget.mediaElement.path}');
      return Container(
        width: width,
        height: height,
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final videoAspectRatio = _videoController!.value.aspectRatio;
    final containerAspectRatio = width / height;

    Widget videoWidget;

    if (videoAspectRatio > containerAspectRatio) {
      final newHeight = width / videoAspectRatio;
      videoWidget = SizedBox(
        width: width,
        height: newHeight,
        child: VideoPlayer(_videoController!),
      );
    } else {
      final newWidth = height * videoAspectRatio;
      videoWidget = SizedBox(
        width: newWidth,
        height: height,
        child: VideoPlayer(_videoController!),
      );
    }

    return Center(
      child: videoWidget,
    );
  }

  // New method to build image widget with file existence check
  Widget _buildImageWidget({required BoxFit fit}) {
    final File imageFile = File(widget.mediaElement.path);
    if (!imageFile.existsSync()) {
      debugPrint(
          'Synchronous check: Media file not found at path: ${widget.mediaElement.path}');
      return Container(
        width: width,
        height: height,
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }

    return Image.file(
      imageFile,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image in Image.file errorBuilder: $error');
        return Container(
          width: width,
          height: height,
          color: Colors.black.withOpacity(0.1),
          child: const Center(
            child: Icon(Icons.error_outline),
          ),
        );
      },
    );
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        ? _buildVideoPlayer()
                                        : _buildImageWidget(
                                            fit: BoxFit.contain),
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
                      ? _buildVideoPlayer()
                      : _buildImageWidget(fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

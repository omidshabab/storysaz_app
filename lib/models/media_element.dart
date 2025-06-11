import 'package:hive/hive.dart';

part 'media_element.g.dart';

@HiveType(typeId: 3)
class MediaElement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final double x;

  @HiveField(3)
  final double y;

  @HiveField(4)
  final double width;

  @HiveField(5)
  final double height;

  @HiveField(6)
  final bool isVideo;

  MediaElement({
    required this.id,
    required this.path,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isVideo,
  });
}

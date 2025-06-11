import 'package:hive/hive.dart';
import 'package:indexed/indexed.dart';

part 'media_element.g.dart';

@HiveType(typeId: 3)
class MediaElement extends HiveObject implements IndexedInterface {
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

  @HiveField(7)
  int index;

  @HiveField(8)
  final double scale;

  MediaElement({
    required this.id,
    required this.path,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isVideo,
    this.index = 0,
    this.scale = 1.0,
  });
}

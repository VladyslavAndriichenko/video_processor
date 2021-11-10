import 'package:video_processor/models/video_item.dart';

abstract class BaseStorage {
  Future<void> saveVideoList(List<VideoItem> videos);
  Future<List<VideoItem>> retrieveVideoList();
}
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_processor/models/video_item.dart';
import 'package:video_processor/storage/base_storage.dart';

class SharedPrefStorage extends BaseStorage {

  final String _videosKey = 'videos_key';

  @override
  Future<List<VideoItem>?> retrieveVideoList() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final json = prefs.get(_videosKey);
      if (json != null) {
        List<Map<String, dynamic>> list = jsonDecode(json as String).cast<Map<String, dynamic>>();
        var videoStatementList = list.map((e) {
          return VideoItem.fromMap(e);
        }).toList();
        return videoStatementList;
      }
      return null;
    } catch (e, stackTrace) {
      print(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveVideoList(List<VideoItem>? videos) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      if (videos?.isEmpty ?? true) {
        await prefs.remove(_videosKey);
      }
      final listOfMap = videos!.map((e) => e.toMap()).toList();
      final json = jsonEncode(listOfMap);
      await prefs.setString(_videosKey, json);
    } catch (e, stackTrace) {
      print(e.toString());
    }
  }

}
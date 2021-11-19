import 'dart:convert';

class VideoItem {
  final int id;
  final String videoName;

  VideoItem({required this.id, this.videoName = ''});

  VideoItem copyWith({String? videoName}) => VideoItem(
    videoName: videoName ?? this.videoName,
    id: id,
  );

  factory VideoItem.fromJson(String str) => VideoItem.fromMap(jsonDecode(str));

  String toJson() => json.encode(toMap());

  factory VideoItem.fromMap(Map<String, dynamic> json) => VideoItem(
    id: json["id"],
    videoName: json["videoName"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "videoName": videoName,
  };
}
import 'dart:convert';

class VideoItem {
  //todo: add ID
  final String? videoName;

  VideoItem({this.videoName,
  });

  VideoItem copyWith({String? videoName, String? videoText}) => VideoItem(
    videoName: videoName ?? this.videoName,
  );

  factory VideoItem.fromJson(String str) => VideoItem.fromMap(jsonDecode(str));

  String toJson() => json.encode(toMap());

  factory VideoItem.fromMap(Map<String, dynamic> json) => VideoItem(
    videoName: json["videoName"],
  );

  Map<String, dynamic> toMap() => {
    "videoName": videoName,
  };
}
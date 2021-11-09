class VideoItem {
  final String videoName;
  // final String videoText;

  VideoItem({this.videoName,
    // this.videoText,
  });

  VideoItem copyWith({String videoName, String videoText}) => VideoItem(
    videoName: videoName ?? this.videoName,
    // videoText: videoText ?? this.videoText,
  );


}
import 'package:flutter/material.dart';

class VideoListItemWidget extends StatelessWidget {
  final String videoName;
  const VideoListItemWidget({Key key, this.videoName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(videoName ?? 'File name'),
    );
  }
}

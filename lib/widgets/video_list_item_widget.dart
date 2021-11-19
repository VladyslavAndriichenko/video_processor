import 'dart:io';

// import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:video_processor/bloc/video_processor/video_processor.dart';
import 'package:video_processor/utils/file_util.dart';

class VideoListItemWidget extends StatelessWidget {
  final String videoName;
  final Function() selectionEvent;
  final VideoProcessorState? state;
  final int id;

  const VideoListItemWidget(
      {Key? key,
      required this.videoName,
      required this.selectionEvent,
      required this.state,
      required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        margin: EdgeInsets.only(left: 10),
        child: Text(videoName),
      ),
      onLongPress: () {
        if (state!.isSelectableMode) return;
        selectionEvent.call();
      },
      onTap: () {
        if (!state!.isSelectableMode) return;
        selectionEvent.call();
      },
      leading: ElevatedButton(
          onPressed: () async {
            final directoryPath = await FileUtil.getAppVideoFilesPath();
            var f = File('$directoryPath/$videoName');
            Share.shareFiles(['${f.path}'], text: 'Share video');
            // Share.file(
            //     'Share video',
            //     videoName,
            //     f.readAsBytesSync(),
            //     'video/mp4');
          },
          child: Text('Share')),
      trailing: state!.isSelectableMode
          ? Checkbox(
              value: state!.selectedItemsIds.contains(id),
              onChanged: (value) {
                selectionEvent.call();
              },
            )
          : SizedBox(),
    );
  }
}

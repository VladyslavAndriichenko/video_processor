import 'package:flutter/material.dart';
import 'package:video_processor/bloc/video_processor/video_processor.dart';

class VideoListItemWidget extends StatelessWidget {
  final String videoName;
  final Function()? selectionEvent;
  final VideoProcessorState? state;
  final int? id;

  const VideoListItemWidget({Key? key, required this.videoName, required this.selectionEvent, required this.state, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(videoName),
      ),
      onLongPress: () {
        if (state!.isSelectableMode) return;
        selectionEvent?.call();
      },
      onTap: () {
        if (!state!.isSelectableMode) return;
        selectionEvent?.call();
      },
      trailing: state!.isSelectableMode
          ? Checkbox(
              value: state!.selectedItemsIds?.contains(id!) ?? false,
              onChanged: (value) {
                selectionEvent?.call();
              },
            )
          : SizedBox(),
    );
  }
}

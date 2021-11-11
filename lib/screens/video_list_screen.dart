import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_processor/bloc/video_processor/video_processor.dart';
import 'package:video_processor/messages.dart';
import 'package:video_processor/models/video_item.dart';
import 'package:video_processor/utils/app_utils.dart';
import 'package:video_processor/utils/permission_util.dart';
import 'package:video_processor/widgets/buttons/common_button.dart';
import 'package:video_processor/widgets/dialogs/basic_dialog.dart';
import 'package:video_processor/widgets/video_list_item_widget.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loaded videos:'),
        actions: [
          BlocBuilder<VideoProcessorBloc, VideoProcessorState>(
            builder: (context, state) => Visibility(
              visible: state.isSelectableMode ?? false,
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: IconButton(
                  splashRadius: 30,
                  icon: Icon(Icons.close),
                  // color: Colors.red,
                  onPressed: () {
                    context.read<VideoProcessorBloc>().add(UnselectAllListItemsEvent());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<VideoProcessorBloc, VideoProcessorState>(
        listener: (context, state) {
          // if (state.) {
          //   showDi
          // }
        },
        builder: (context, state) {
          if (state.isLoading()) {
            return Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // todo: try to make it reusable
                    child: ListView(
                      padding: EdgeInsets.symmetric(),
                      children: indexedMap(
                        state.videoCardList?.isEmpty ?? true ? List.empty() : state.videoCardList!,
                        (index, dynamic videoCard) => ListTile(
                          title: VideoListItemWidget(videoName: videoCard.videoName),
                          onLongPress: () {
                            context
                                .read<VideoProcessorBloc>()
                                .add(SelectVideoListItemEvent(videoIndex: index));
                          },
                          onTap: () {
                            if (!state.isSelectableMode) return;
                            context
                                .read<VideoProcessorBloc>()
                                .add(SelectVideoListItemEvent(videoIndex: index));
                          },
                          trailing: state.isSelectableMode
                              ? Checkbox(
                                  value: state.selectedItemsIndexes?.contains(index) ?? false,
                                  onChanged: (value) {
                                    context
                                        .read<VideoProcessorBloc>()
                                        .add(SelectVideoListItemEvent(videoIndex: index));
                                  },
                                )
                              : SizedBox(),
                        ),
                      ).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          onClick: () async {
                            var permissionResult = await PermissionUtil.askPermissions(
                                context, [Permission.camera, Permission.storage, Permission.photos],
                                () {
                              showDialog(
                                context: context,
                                builder: (context) => BasicDialog(
                                  headerText: Messages.askPermissionsTitle,
                                  contentText: Messages.askPermissionsMessage,
                                  useCancel: true,
                                  actionButtonText: 'Open',
                                  action: () => openAppSettings(),
                                ),
                              );
                            });
                            if (permissionResult) {
                              context.read<VideoProcessorBloc>().add(PickUpVideoEvent(context));
                            }
                          },
                          buttonText: 'Choose video',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: CommonButton(
                          onClick: (state.selectedItemsIndexes?.isEmpty ?? true)
                              ? null
                              : () {
                                  context.read<VideoProcessorBloc>().add(DeleteSelectedVideosEvent(
                                      indexesForDelete: state.selectedItemsIndexes));
                                },
                          buttonText: 'Delete videos',
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

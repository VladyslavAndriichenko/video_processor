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
    return WillPopScope(
      onWillPop: () async {
        if (context.read<VideoProcessorBloc>().state.isSelectableMode) {
          context.read<VideoProcessorBloc>().add(UnselectAllListItemsEvent());
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: BlocBuilder<VideoProcessorBloc, VideoProcessorState>(
              buildWhen: (prev, cur) =>
                  prev.isSelectableMode != cur.isSelectableMode ||
                  prev.selectedItemsIds.length != cur.selectedItemsIds.length,
              builder: (context, state) => Text(state.isSelectableMode
                  ? 'Selected items ${state.selectedItemsIds.length}'
                  : 'Video List'),
            ),
            actions: [
              BlocBuilder<VideoProcessorBloc, VideoProcessorState>(
                buildWhen: (prev, cur) => prev.isSelectableMode != cur.isSelectableMode,
                builder: (context, state) => Visibility(
                  visible: state.isSelectableMode,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: IconButton(
                      splashRadius: 30,
                      icon: Icon(Icons.close),
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
              return Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildVideoListView(state, context),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      child: buildButtons(context, state),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context, VideoProcessorState state) {
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            onClick: () async {
              var permissionResult = await PermissionUtil.askPermissions(
                  context, [Permission.camera, Permission.storage, Permission.photos], () {
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
                context.read<VideoProcessorBloc>().add(PickAndProcessVideoEvent());
              }
            },
            buttonText: 'Choose video',
          ),
        ),
        SizedBox(width: 20),
        if (state.isSelectableMode)
        Expanded(
          child: CommonButton(
            onClick: (state.selectedItemsIds.isEmpty)
                ? null
                : () {
              context
                  .read<VideoProcessorBloc>()
                  .add(DeleteSelectedVideosEvent(videosIds: state.selectedItemsIds));
            },
            buttonText: 'Delete videos',
          ),
        ),
        if (!state.isSelectableMode)
        Expanded(
          child: CommonButton(
            onClick: (state.videoCardList.isEmpty)
                ? null
                : () {
                    context
                        .read<VideoProcessorBloc>()
                        .add(CombineVideosEvent());
                  },
            buttonText: 'Combine videos',
          ),
        )
      ],
    );
  }

  ListView buildVideoListView(VideoProcessorState state, BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: indexedMap<Widget, VideoItem>(
        state.videoCardList.isEmpty ? List.empty() : state.videoCardList,
        (index, videoItem) => VideoListItemWidget(
          videoName: videoItem.videoName,
          selectionEvent: () {
            context
                .read<VideoProcessorBloc>()
                .add(SelectVideoListItemEvent(videoId: videoItem.id));
          },
          id: videoItem.id,
          state: state,
        ),
      ).toList(),
    );
  }
}

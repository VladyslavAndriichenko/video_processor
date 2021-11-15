import 'package:video_processor/models/video_item.dart';

enum VideoProcessorStateStatus { uninitialized, initialized, loading }

class VideoProcessorState {
  final VideoProcessorStateStatus? status;
  final List<VideoItem>? videoCardList;
  final bool hasCombinedVideo;
  final List<int>? selectedItemsIds;
  final bool isSelectableMode;
  final String? errorMessage;

  VideoProcessorState(
      {this.status,
      this.videoCardList,
      this.hasCombinedVideo = false,
      this.selectedItemsIds,
      this.errorMessage,
      this.isSelectableMode = false});

  VideoProcessorState.uninitialized()
      : this(status: VideoProcessorStateStatus.uninitialized, isSelectableMode: false);

  VideoProcessorState.loading()
      : this(
          status: VideoProcessorStateStatus.loading,
        );

  VideoProcessorState.initialized({List<VideoItem>? videoCardList})
      : this(status: VideoProcessorStateStatus.initialized, videoCardList: videoCardList ?? []);

  bool isLoading() => status == VideoProcessorStateStatus.loading;

  bool isInitialized() => status == VideoProcessorStateStatus.initialized;

  VideoProcessorState copyWith(
          {VideoProcessorStateStatus? status,
          List<VideoItem>? videoCardList,
          bool? hasCombinedVideo,
          List<int>? selectedItemsIds,
          bool? isSelectableMode,
          String errorMessage = ''}) =>
      VideoProcessorState(
        status: status ?? this.status,
        videoCardList: videoCardList ?? this.videoCardList,
        hasCombinedVideo: hasCombinedVideo ?? this.hasCombinedVideo,
        selectedItemsIds: selectedItemsIds ?? this.selectedItemsIds,
        isSelectableMode: isSelectableMode ?? this.isSelectableMode,
        errorMessage: errorMessage,
      );
// VideoProcessorState.initialized({}) : this._(status : VideoProcessorStateStatus.initialized);
}

import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_processor/app.dart';
import 'package:video_processor/bloc/video_processor/video_processor_event.dart';
import 'package:video_processor/bloc/video_processor/video_processor_state.dart';
import 'package:video_processor/models/video_item.dart';
import 'package:video_processor/storage/base_storage.dart';
import 'package:video_processor/utils/video_processor.dart';
import 'package:video_processor/widgets/dialogs/basic_dialog.dart';
import 'package:path/path.dart';

class VideoProcessorBloc extends Bloc<VideoProcessorEvent, VideoProcessorState> {

  final BaseStorage? storage;

  VideoProcessorBloc({this.storage}) : super(const VideoProcessorState());

  // on<InitializeVideoProcessor>((event, emit) => _initializeVideoProcessor(event));
  // on<PickAndProcessVideoEvent>((event, emit) => _pickAndProcessVideoEvent(event));
  // on<SelectVideoListItemEvent>((event, emit) => _selectVideoListItemEvent(event));
  // on<UnselectAllListItemsEvent>((event, emit) => _unselectAllListItemsEvent(event));
  // on<DeleteSelectedVideosEvent>((event, emit) => _deleteSelectedVideosEvent(event));
  // on<CombineVideosEvent>((event, emit) => _combineVideosEvent(event));

  @override
  Stream<VideoProcessorState> mapEventToState(VideoProcessorEvent event) async* {
    if (event is InitializeVideoProcessor) {
      yield* _initializeVideoProcessor(event);
    } else if (event is PickAndProcessVideoEvent) {
      yield* _pickAndProcessVideoEvent(event);
    } else if (event is SelectVideoListItemEvent) {
      yield* _selectVideoListItemEvent(event);
    } else if (event is UnselectAllListItemsEvent) {
      yield* _unselectAllListItemsEvent(event);
    } else if (event is DeleteSelectedVideosEvent) {
      yield* _deleteSelectedVideosEvent(event);
    } else if (event is CombineVideosEvent) {
      yield* _combineVideosEvent(event);
    }
  }

  Stream<VideoProcessorState> _initializeVideoProcessor(InitializeVideoProcessor event) async* {
    final savedVideos = await storage!.retrieveVideoList();
    yield VideoProcessorState.initialized(videoCardList: savedVideos);
  }

  Stream<VideoProcessorState> _pickAndProcessVideoEvent(PickAndProcessVideoEvent event) async* {
    if (!state.isInitialized()) return;

    final VideoProcessorState curState = state;

    yield VideoProcessorState.loading();
    ImageSource? videoSource;

    await showDialog<bool>(
      useRootNavigator: false,
      context: globalKey.currentContext!,
      builder: (context) => BasicDialog(
          useCancel: false,
          actionButtonText: 'Gallery',
          action: () {
            videoSource = ImageSource.gallery;
          },
          action2ButtonText: 'Camera',
          action2: () {
            videoSource = ImageSource.camera;
          },
          headerText: 'Record Video',
          contentText:
          'There is a 1 minute limit per recording. Should your recording exceed 1 minute, the video will be automatically cut.'),
    );

    if (videoSource == null) return;

    final picker = ImagePicker();
    var pickedFile;
    try {
      pickedFile = await picker.pickVideo(source: videoSource!, maxDuration: Duration(seconds: 60));
      if (pickedFile == null || pickedFile.path == null || pickedFile.path.isEmpty) {
        yield curState.copyWith();
        return;
      }

      var videoProcessor = VideoProcessor(ffmpeg: FlutterFFmpeg());
      final cutVideoPath = await videoProcessor.cutVideo(pickedFile.path, pickedFile.path.hashCode.toString());

      ///delete video which picked from camera
      if (videoSource == ImageSource.camera) await File(pickedFile.path).delete();

      final newVideoList = curState.videoCardList..add(VideoItem(id: DateTime.now().millisecondsSinceEpoch, videoName: basename(cutVideoPath)));
      await storage!.saveVideoList(newVideoList);
      yield curState.copyWith(videoCardList: newVideoList);
    } catch (e, stackTrace) {
      yield curState.copyWith(errorMessage: e.toString());
      return;
    }
  }

  Stream<VideoProcessorState> _selectVideoListItemEvent(SelectVideoListItemEvent event) async* {
    if (!state.isInitialized()) return;

    ///if selected items list is empty, init list and add new selection
    if (state.selectedItemsIds.isEmpty) {
      yield state.copyWith(selectedItemsIds: [event.videoId], isSelectableMode: true);
    } else {
      ///if contain item, remove
      if (state.selectedItemsIds.contains(event.videoId)) {
        var selectedItems = [...state.selectedItemsIds];
        selectedItems..removeWhere((id) => id == event.videoId);
        yield state.copyWith(selectedItemsIds: selectedItems, isSelectableMode: true);
      }
      ///if not, add
      else {
        var selectedItems = [...state.selectedItemsIds];
        selectedItems..add(event.videoId);
        yield state.copyWith(selectedItemsIds: selectedItems, isSelectableMode: true);
      }
    }
  }

  Stream<VideoProcessorState> _unselectAllListItemsEvent(UnselectAllListItemsEvent event) async* {
    if (!state.isInitialized()) return;

    yield state.copyWith(selectedItemsIds: [], isSelectableMode: false);
  }

  Stream<VideoProcessorState> _deleteSelectedVideosEvent(DeleteSelectedVideosEvent event) async* {
    if (!state.isInitialized()) return;

    if (event.videosIds.isEmpty) return;

    var allItems = [...state.videoCardList];
    allItems.removeWhere((videoItem) => event.videosIds.contains(videoItem.id));

    try {
      await storage!.saveVideoList(allItems);
    } catch (e) {
      print(e);
    }

    yield state.copyWith(selectedItemsIds: [], videoCardList: allItems, isSelectableMode: false);
  }

  Stream<VideoProcessorState> _combineVideosEvent(CombineVideosEvent event) async* {
    if (!state.isInitialized()) return;

    if (state.videoCardList.isEmpty) return;

    try {
      await VideoProcessor(ffmpeg: FlutterFFmpeg()).combineVideosReturnFileName(state.videoCardList.map((videoItem) => videoItem.videoName).toList());
    } catch (e) {
      yield state.copyWith(errorMessage: e.toString());
      return;
    }
  }
}
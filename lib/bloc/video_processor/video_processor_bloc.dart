import 'dart:io';

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

// todo: Migrate to flutter 2.0
// todo: USE linter from provider starter
// todo: use bloc version 7+
class VideoProcessorBloc extends Bloc<VideoProcessorEvent, VideoProcessorState> {

  final BaseStorage? storage;

  VideoProcessorBloc({this.storage}) : super(VideoProcessorState.uninitialized());

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

      final newVideoList = curState.videoCardList!..add(VideoItem(id: DateTime.now().millisecondsSinceEpoch, videoName: basename(cutVideoPath)));
      await storage!.saveVideoList(newVideoList);
      yield curState.copyWith(videoCardList: newVideoList);
    } catch (e, stackTrace) {
      yield curState.copyWith(errorMessage: e.toString());
      return;
    }
  }

  Stream<VideoProcessorState> _selectVideoListItemEvent(SelectVideoListItemEvent event) async* {
    if (!state.isInitialized()) return;

    if (state.selectedItemsIndexes?.isEmpty ?? true) {
      yield state.copyWith(selectedItemsIndexes: [event.videoIndex], isSelectableMode: true);
    } else {
      ///if contains selected item, do nothing
      if (state.selectedItemsIndexes!.contains(event.videoIndex)) {
        state.selectedItemsIndexes!..remove(event.videoIndex);
        //todo: RELY ON VIDEO ID
        // final list = [...state.selectedItemsIndexes.where((element) => element.id != event.id)];
        yield state.copyWith(selectedItemsIndexes: state.selectedItemsIndexes!..remove(event.videoIndex), isSelectableMode: true);
      } else {
        yield state.copyWith(selectedItemsIndexes: state.selectedItemsIndexes!..add(event.videoIndex), isSelectableMode: true);
      }
    }
  }

  Stream<VideoProcessorState> _unselectAllListItemsEvent(UnselectAllListItemsEvent event) async* {
    if (!state.isInitialized()) return;

    yield state.copyWith(selectedItemsIndexes: [], isSelectableMode: false);
  }
}
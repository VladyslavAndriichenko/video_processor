import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_processor/app.dart';
import 'package:video_processor/bloc/video_processor/video_processor_event.dart';
import 'package:video_processor/bloc/video_processor/video_processor_state.dart';
import 'package:video_processor/models/video_item.dart';
import 'package:video_processor/utils/video_processor.dart';
import 'package:video_processor/widgets/dialogs/basic_dialog.dart';
import 'package:path/path.dart';

class VideoProcessorBloc extends Bloc<VideoProcessorEvent, VideoProcessorState> {
  VideoProcessorBloc() : super(VideoProcessorState.uninitialized());

  @override
  Stream<VideoProcessorState> mapEventToState(VideoProcessorEvent event) async* {
    if (event is InitializeVideoProcessor) {
      yield* _initializeVideoProcessor(event);
    } else if (event is PickUpVideoEvent) {
      yield* _pickVideoEvent(event);
    } else if (event is SelectVideoListItemEvent) {
      yield* _selectVideoListItemEvent(event);
    } else if (event is UnselectAllListItemsEvent) {
      yield* _unselectAllListItemsEvent(event);
    }
  }

  Stream<VideoProcessorState> _initializeVideoProcessor(InitializeVideoProcessor event) async* {
    yield VideoProcessorState.initialized();
  }

  Stream<VideoProcessorState> _pickVideoEvent(PickUpVideoEvent event) async* {
    if (!state.isInitialized()) return;

    final curState = state;

    yield VideoProcessorState.loading();
    ImageSource videoSource;

    await showDialog<bool>(
      useRootNavigator: false,
      // context: event.context,
      context: globalKey.currentContext,
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
    PickedFile pickedFile;

    try {
      pickedFile = await picker.getVideo(source: videoSource, maxDuration: Duration(seconds: 60));

      if (pickedFile == null || pickedFile.path == null || pickedFile.path.isEmpty) {
        yield curState.copyWith();
        return;
      }
      var videoProcessor = VideoProcessor(ffmpeg: FlutterFFmpeg());
      final cutVideoPath = await videoProcessor.cutVideo(pickedFile.path, pickedFile.path.hashCode.toString());

      if (videoSource == ImageSource.camera) await File(pickedFile.path).delete();
      // final List<VideoItem> newList = [VideoItem(videoName: basename(cutVideoPath))];
      yield curState.copyWith(videoCardList: curState.videoCardList..add(VideoItem(videoName: basename(cutVideoPath))));
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
      if (state.selectedItemsIndexes.contains(event.videoIndex)) {
        yield state.copyWith(selectedItemsIndexes: state.selectedItemsIndexes..remove(event.videoIndex), isSelectableMode: true);
      } else {
        yield state.copyWith(selectedItemsIndexes: state.selectedItemsIndexes..add(event.videoIndex), isSelectableMode: true);
      }
    }
  }

  Stream<VideoProcessorState> _unselectAllListItemsEvent(UnselectAllListItemsEvent event) async* {
    if (!state.isInitialized()) return;

    yield state.copyWith(selectedItemsIndexes: [], isSelectableMode: false);
  }
}
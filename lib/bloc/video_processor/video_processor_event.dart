import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class VideoProcessorEvent {}

class InitializeVideoProcessor extends VideoProcessorEvent {}
class PickUpVideoEvent extends VideoProcessorEvent {
  // todo: REMOVE!
  final BuildContext context;

  PickUpVideoEvent(this.context);
}
class DeleteSelectedVideosEvent extends VideoProcessorEvent {
  final List<int>? indexesForDelete;

  DeleteSelectedVideosEvent({required this.indexesForDelete});
}
class SelectVideoListItemEvent extends VideoProcessorEvent {
  final int videoIndex;

  SelectVideoListItemEvent({required this.videoIndex});
}
class UnselectAllListItemsEvent extends VideoProcessorEvent {}
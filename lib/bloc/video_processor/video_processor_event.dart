import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class VideoProcessorEvent {}

class InitializeVideoProcessor extends VideoProcessorEvent {}
class PickAndProcessVideoEvent extends VideoProcessorEvent {}
class DeleteSelectedVideosEvent extends VideoProcessorEvent {
  final List<int>? indexesForDelete;

  DeleteSelectedVideosEvent({required this.indexesForDelete});
}
class SelectVideoListItemEvent extends VideoProcessorEvent {
  final int videoIndex;

  SelectVideoListItemEvent({required this.videoIndex});
}
class UnselectAllListItemsEvent extends VideoProcessorEvent {}
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class VideoProcessorEvent {}

class InitializeVideoProcessor extends VideoProcessorEvent {}
class PickAndProcessVideoEvent extends VideoProcessorEvent {}
class DeleteSelectedVideosEvent extends VideoProcessorEvent {
  final List<int>? videosIds;

  DeleteSelectedVideosEvent({required this.videosIds});
}
class SelectVideoListItemEvent extends VideoProcessorEvent {
  final int videoId;

  SelectVideoListItemEvent({required this.videoId});
}
class UnselectAllListItemsEvent extends VideoProcessorEvent {}
class CombineVideosEvent extends VideoProcessorEvent {}
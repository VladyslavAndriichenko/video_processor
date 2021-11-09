import 'package:flutter/material.dart';
import 'package:video_processor/screens/video_list_screen.dart';

const String videoListScreenRoute = '/videoListScreen';

Map<String, WidgetBuilder> applicationRoutes = <String, WidgetBuilder>{
  videoListScreenRoute: (context) => VideoListScreen(),
};
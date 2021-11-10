import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_processor/bloc/video_processor/video_processor.dart';
import 'package:video_processor/routes.dart';
import 'package:video_processor/screens/splash_screen.dart';
import 'package:video_processor/screens/video_list_screen.dart';
import 'package:video_processor/storage/shared_pref_storage.dart';

import 'bloc/video_processor/video_processor_bloc.dart';

GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideoProcessorBloc(storage: SharedPrefStorage())..add(InitializeVideoProcessor()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: globalKey,
        title: 'Flutter Demo',
        routes: applicationRoutes,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

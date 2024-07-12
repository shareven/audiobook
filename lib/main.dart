import 'dart:async';

import 'package:audiobook/config/Global.dart';
import 'package:audiobook/pages/audio/Audio.dart';
import 'package:audiobook/provide/audio_provide.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'audiobook Audio',
    androidNotificationOngoing: true,
  );

  WidgetsFlutterBinding.ensureInitialized();

  Provider.debugCheckInvalidValueType = null;
  final provides = [
    Provider<AudioProvide>(create: (_) => AudioProvide()),
  ];

  runApp(MultiProvider(providers: provides, child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 初始化audio | Init audio
    Provider.of<AudioProvide>(context, listen: false).audioInit();

    return OverlaySupport.global(
      child: MaterialApp(
        theme: ThemeData(
          cardTheme: CardTheme(
              color: Colors.white, elevation: 0, margin: EdgeInsets.zero),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white54,
          ),
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Global.themeColor,
          ),
          primarySwatch: Global.themeColor,
          colorScheme: ColorScheme.fromSeed(seedColor: Global.themeColor),
          useMaterial3: true,
        ),
        home: Audio(),
      ),
    );
  }
}

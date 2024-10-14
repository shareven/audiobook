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
    ChangeNotifierProvider(create: (_) => AudioProvide()),
  ];

  runApp(MultiProvider(providers: provides, child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 初始化audio | Init audio
    context.read<AudioProvide>().audioInit();

    return OverlaySupport.global(
      child: MaterialApp(
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          cardTheme: const CardTheme(
              color: Color.fromARGB(221, 28, 28, 28),
              elevation: 0,
              margin: EdgeInsets.zero),
          colorScheme: const ColorScheme.dark(
            surface: Color.fromARGB(248, 17, 17, 17),
            primary: Global.themeColor,
            onPrimary: Colors.white,
            secondary: Colors.cyan,
          ),
        ),
        theme: ThemeData(
          cardTheme: const CardTheme(
              color: Colors.white, elevation: 0, margin: EdgeInsets.zero),
          tabBarTheme: const TabBarTheme(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white54,
          ),
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Global.themeColor,
          ),
          primarySwatch: Global.themeColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Global.themeColor,
            primary: Global.themeColor,
            secondary: Colors.cyan,
          ),
          useMaterial3: true,
        ),
        home: Audio(),
      ),
    );
  }
}

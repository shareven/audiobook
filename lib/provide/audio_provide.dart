import 'package:audio_session/audio_session.dart';
import 'package:audiobook/config/Global.dart';
import 'package:audiobook/model/book_model.dart';
import 'package:audiobook/utils/LocalStorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audiobook/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

AudioPlayer player = AudioPlayer();

class AudioProvide with ChangeNotifier {
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  Future<List<AudioSource>> _getCurrentBookItems() async {
    BookModel? res = await LocalStorage.getCurrentBookVal();
    bool isLocalBook = await LocalStorage.getIsLocalBook();
    String bookLocalPath = await LocalStorage.getLocalBookDirectory();

    BookModel book = res ?? Global.books[0];
    List<AudioSource> items = List.generate(
      book.end - book.start + 1,
      (i) {
        int index = book.start + i;
        String str = "第${index}集 | E ${index}";
        String fileName = "${book.name}$index.m4a";
        return AudioSource.uri(
          isLocalBook
              ? Uri.file('${bookLocalPath}/${book.name}/${fileName}')
              : Uri.parse('${Global.bookBaseUrl}/${book.name}/${fileName}'),
          tag: MediaItem(
            id: '$i',
            album: str,
            title: "${book.name} $str",
            artist: str,
            artUri: Uri.parse(book.artUrl),
          ),
        );
      },
    );
    return items;
  }

  Future<void> audioInit() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    List<Duration> bookSkipSeconds = await LocalStorage.getPlaySkipSeconds();

    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    player.positionStream.listen((position) {
      //  记录播放位置 3s保存一次 | Record playback position and save once every 3 seconds
      if (player.playing &&
          player.currentIndex != null &&
          position.inSeconds != 0 &&
          position.inSeconds % Global.autoSaveSeconds == 0) {
        LocalStorage.setPlayRecordVal(
            [player.currentIndex, position.inSeconds]);
      }

      if (position.inMilliseconds < bookSkipSeconds[0].inMilliseconds &&
          player.playing) {
        // 刚开始播放时设置跳过片头 | Set to skip the opening when starting playback
        player.seek(bookSkipSeconds[0]);
      }

      // 播到快结束时设置跳过片尾 | Set to skip the ending when the video is almost finished
      if (player.duration != null &&
          position.inMilliseconds >
              player.duration!.inMilliseconds -
                  bookSkipSeconds[1].inMilliseconds) {
        player.seekToNext();
      }
    });
    setPlayBookItems();
    notifyListeners();
  }

  setPlayBookItems() async {
    try {
      // 请求权限 | Permission request
      await Permission.audio.request();

      var status = await Permission.audio.status;
      if (status.isGranted) {
        List<AudioSource> list = await _getCurrentBookItems();
        _playlist = ConcatenatingAudioSource(children: list);
        try {
          await player.setAudioSource(_playlist);
        } catch (e) {
          showErrorMsg(e.toString());
        }
        _getRecord();
      } else {
        showErrorMsg("音频权限获取失败 | Failed to obtain audio permission");
      }
    } catch (e, stackTrace) {
      print("Error loading playlist: $e");
      print(stackTrace);
    }
    notifyListeners();
  }

  _getRecord() async {
    var res = await LocalStorage.getPlayRecordVal();
    if (res != null) {
      await player.seek(Duration(seconds: res[1]), index: res[0]);
    }
  }
}

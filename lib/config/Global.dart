import 'package:audiobook/model/book_model.dart';
import 'package:flutter/material.dart';

class Global {
  static const themeColor = Colors.pink;
  static const String bookNetworkUrl = "https://cdn.jsdelivr.net/gh/shareven/audiobookResource";
  static const String bookLocalPath = "/storage/emulated/0/Music/book";

  // 每3s自动保存播放进度 | Automatically save playback progress every 3 seconds
  static const int autoSaveSeconds = 3;

  // name书名  artUrl图片地址  start开始集数 end结束集数
  static List<BookModel> books = [
    BookModel.fromJson({
      "name": "凡人修仙传",
      "artUrl":
          "https://imagev2.xmcdn.com/storages/fe9f-audiofreehighqps/D9/DA/GKwRIJEGGtnIAAOdbwEyhidG.jpeg!strip=1&quality=7&magick=webp&op_type=5&upload_type=cover&name=web_large&device_type=ios",
      "start": 1,
      "end": 8,
    }),
  ];
}

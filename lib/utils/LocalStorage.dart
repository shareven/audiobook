import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:audiobook/config/Global.dart';
import 'package:audiobook/model/book_model.dart';

class LocalStorage {
  static const String playRecordKey = "playRecordKey";
  static const String playSkipSecondsKey = "playSkipSecondsKey";
  static const String booksKey = "booksKey";
  static const String currentBookKey = "currentBookKey";
  static const String isLocalBookKey = "isLocalBookKey";
  static const String localBookDirectoryKey = "localBookDirectoryKey";
  static const String networkBookUrlKey = "networkBookUrlKey";

  static Future<bool?> setBooksVal(List list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(booksKey, jsonEncode(list));
  }

  static Future<List<BookModel>> getBooksVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(booksKey);
    if (val != null) {
      try {
        List list = jsonDecode(val);
        return list.map((e) => BookModel.fromJson(e)).toList();
      } catch (e) {
        print(e);
      }
    }
    return [];
  }

  static Future<bool?> setCurrentBookVal(BookModel book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(currentBookKey, jsonEncode(book.toJson()));
  }

  static Future<BookModel?> getCurrentBookVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(currentBookKey);
    if (val != null) {
      try {
        var data = jsonDecode(val);
        return BookModel.fromJson(data);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  /// [ _player.currentIndex, position.inSeconds]
  static Future<bool?> setPlayRecordVal(List list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(playRecordKey, jsonEncode(list));
  }

  static Future<List?> getPlayRecordVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(playRecordKey);
    return val != null ? jsonDecode(val) : null;
  }

  static Future<bool> setPlaySkipSeconds(List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(playSkipSecondsKey, jsonEncode((list)));
  }

  static Future<List<Duration>> getPlaySkipSeconds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(playSkipSecondsKey);
    if (val != null) {
      try {
        List list = jsonDecode(val);
        return list.map((e) => Duration(seconds: int.parse(e))).toList();
      } catch (e) {
        print(e);
      }
    }
    return [Duration.zero, Duration.zero];
  }

  static Future<void> setIsLocalBook(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(isLocalBookKey, value);
  }

  static Future<bool> getIsLocalBook() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLocalBookKey) ?? false;
  }

  static Future<bool> setLocalBookDirectory(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(localBookDirectoryKey, val);
  }

  static Future<String> getLocalBookDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(localBookDirectoryKey) ?? Global.bookLocalPath;
  }

  static Future<bool> setNetworkBookUrl(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(networkBookUrlKey, val);
  }

  static Future<String> getNetworkBookUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(networkBookUrlKey);
    return val == null || val.isEmpty ? Global.bookNetworkUrl : val;
  }
}

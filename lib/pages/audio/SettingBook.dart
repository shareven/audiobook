import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audiobook/config/Global.dart';
import 'package:audiobook/provide/audio_provide.dart';
import 'package:audiobook/utils/LocalStorage.dart';

class SettingBook extends StatefulWidget {
  const SettingBook({super.key});
  @override
  State<SettingBook> createState() => _SettingBookState();
}

class _SettingBookState extends State<SettingBook> {
  String _skipSecondsStart = "0";
  String _selectedDirectory = "";
  bool _isLocalBook = false;
  TextEditingController _skipSecondsStartController =
      new TextEditingController(text: "");

  FocusNode _focusNodeSkipSecondsStart = FocusNode();
  String _skipSecondsEnd = "0";
  TextEditingController _skipSecondsEndController =
      new TextEditingController(text: "");

  FocusNode _focusNodeSkipSecondsEnd = FocusNode();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
    _skipSecondsStartController.dispose();
    _focusNodeSkipSecondsStart.dispose();
    _skipSecondsEndController.dispose();
    _focusNodeSkipSecondsEnd.dispose();
  }

  void _getData() async {
    List<Duration> list = await LocalStorage.getPlaySkipSeconds();
    bool isLocalBook = await LocalStorage.getIsLocalBook();
    String localBookDirectory = await LocalStorage.getLocalBookDirectory();
    _skipSecondsStartController.text = list[0].inSeconds.toString();
    _skipSecondsStart = list[0].inSeconds.toString();
    _skipSecondsEndController.text = list[1].inSeconds.toString();
    _skipSecondsEnd = list[1].inSeconds.toString();
    setState(() {
      _isLocalBook = isLocalBook;
      _selectedDirectory = localBookDirectory;
    });
  }

  void _post() async {
    var isSuccess = await LocalStorage.setPlaySkipSeconds(
        [_skipSecondsStart, _skipSecondsEnd]);
    await LocalStorage.setIsLocalBook(_isLocalBook);
    await LocalStorage.setLocalBookDirectory(_selectedDirectory);
    if (isSuccess) {
      Provider.of<AudioProvide>(context, listen: false).setPlayBookItems();

      Navigator.pop(context);
    }
  }

  selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
    }
    setState(() {
      _selectedDirectory = selectedDirectory ?? "";
    });
  }

  Widget buildIsLocalBook(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          title: Text("网络音频 | Network Audio"),
          value: false,
          onChanged: (value) {
            setState(() {
              _isLocalBook = false;
            });
          },
          groupValue: _isLocalBook,
          activeColor: Global.themeColor,
        ),
        RadioListTile(
          title: Text("本地音频 | Local Audio"),
          value: true,
          onChanged: (value) {
            setState(() {
              _isLocalBook = true;
            });
          },
          groupValue: _isLocalBook,
          activeColor: Global.themeColor,
        ),
        _isLocalBook
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      child: Text("选择音频目录 | Select audio directory"),
                      onPressed: selectDirectory,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(_selectedDirectory),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("设置 | Setting"),
          actions: [
            IconButton(
                onPressed: _skipSecondsStart.isNotEmpty ? _post : null,
                icon: Icon(Icons.check))
          ],
        ),
        body: ListView(
          children: [
            buildIsLocalBook(context),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("跳过片头秒数 | Skip opening"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (e) {
                  setState(() {
                    _skipSecondsStart = e.trim();
                  });
                },
                keyboardType: TextInputType.number,
                focusNode: _focusNodeSkipSecondsStart,
                controller: _skipSecondsStartController,
                onSubmitted: (e) => _focusNodeSkipSecondsEnd.requestFocus(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片头秒数 | Skip opening",
                    suffixText: "s"),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("跳过片尾秒数 | Skip the end"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (e) {
                  setState(() {
                    _skipSecondsEnd = e.trim();
                  });
                },
                keyboardType: TextInputType.number,
                focusNode: _focusNodeSkipSecondsEnd,
                controller: _skipSecondsEndController,
                onSubmitted: (e) => _post(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片尾秒数 | Skip the end",
                    suffixText: "s"),
              ),
            ),
          ],
        ));
  }
}

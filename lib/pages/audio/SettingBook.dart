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
  final _formKey = GlobalKey<FormState>();
  String _selectedDirectory = "";
  bool _isLocalBook = false;
  TextEditingController _networkUrlController =
      new TextEditingController(text: "");
  TextEditingController _skipSecondsStartController =
      new TextEditingController(text: "0");

  FocusNode _focusNodeSkipSecondsStart = FocusNode();
  TextEditingController _skipSecondsEndController =
      new TextEditingController(text: "0");

  FocusNode _focusNodeSkipSecondsEnd = FocusNode();
  bool _enableBtn = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
    _networkUrlController.dispose();
    _skipSecondsStartController.dispose();
    _focusNodeSkipSecondsStart.dispose();
    _skipSecondsEndController.dispose();
    _focusNodeSkipSecondsEnd.dispose();
  }

  void _getData() async {
    List<Duration> list = await LocalStorage.getPlaySkipSeconds();
    bool isLocalBook = await LocalStorage.getIsLocalBook();
    String localBookDirectory = await LocalStorage.getLocalBookDirectory();
    String networkBookUrl = await LocalStorage.getNetworkBookUrl();
    _skipSecondsStartController.text = list[0].inSeconds.toString();
    _skipSecondsEndController.text = list[1].inSeconds.toString();
    _networkUrlController.text = networkBookUrl;
    setState(() {
      _isLocalBook = isLocalBook;
      _selectedDirectory = localBookDirectory;
    });
  }

  void _post() async {
    var isSuccess = await LocalStorage.setPlaySkipSeconds([
      _skipSecondsStartController.text.trim(),
      _skipSecondsEndController.text.trim()
    ]);
    await LocalStorage.setIsLocalBook(_isLocalBook);
    if (_isLocalBook) {
      await LocalStorage.setLocalBookDirectory(_selectedDirectory);
    } else {
      await LocalStorage.setNetworkBookUrl(_networkUrlController.text.trim());
    }
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text("网络音频地址 | Network audio url"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      validator: (v) {
                        if (v != null && v.trim().isEmpty) {
                          return null;
                        }
                        if (v != null && !v.trim().startsWith("http")) {
                          return "需http开头 | Must start with http";
                        }
                        return null;
                      },
                      controller: _networkUrlController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(1),
                        hintText: "https://audiobook-resource.vercel.app",
                      ),
                    ),
                  ),
                ],
              ),
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
                onPressed: _enableBtn ? _post : null, icon: Icon(Icons.check))
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () =>
              setState(() => _enableBtn = _formKey.currentState!.validate()),
          child: ListView(
            children: [
              buildIsLocalBook(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Text("跳过片头秒数 | Skip opening"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是数字 | Must number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeSkipSecondsStart,
                  controller: _skipSecondsStartController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片头秒数 | Skip opening",
                    suffixText: "s",
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Text("跳过片尾秒数 | Skip the end"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是数字 | Must number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeSkipSecondsEnd,
                  controller: _skipSecondsEndController,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片尾秒数 | Skip the end",
                    suffixText: "s",
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

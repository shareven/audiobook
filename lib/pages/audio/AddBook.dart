import 'package:flutter/material.dart';
import 'package:audiobook/model/book_model.dart';
import 'package:audiobook/utils/LocalStorage.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  String _bookName = "";
  String _artUrl = "";
  int _start = 1;
  int _end = 100;
  TextEditingController _startController = new TextEditingController(text: "1");
  TextEditingController _endController = new TextEditingController(text: "100");
  FocusNode _focusNodeBookName = FocusNode();
  FocusNode _focusNodeArtUrl = FocusNode();
  FocusNode _focusNodeStart = FocusNode();
  FocusNode _focusNodeEnd = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeBookName.dispose();
    _focusNodeArtUrl.dispose();
    _focusNodeStart.dispose();
    _focusNodeEnd.dispose();
    _startController.dispose();
    _endController.dispose();
  }

  Future _post() async {
    BookModel book = BookModel(_bookName, _artUrl, _start, _end);
    List<BookModel> books = await LocalStorage.getBooksVal();
    int index = books.indexWhere((e) => e.name == book.name);
    if (index != -1) {
      books.removeAt(index);
    }
    books.insert(0, book);
    List list = books.map((e) => e.toJson()).toList();
    LocalStorage.setBooksVal(list);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("添加书 | Add book"),
          actions: [
            IconButton(
                onPressed: _bookName.isNotEmpty ? _post : null,
                icon: Icon(Icons.check))
          ],
        ),
        body: Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  onChanged: (e) {
                    setState(() {
                      _bookName = e.trim();
                    });
                  },
                  focusNode: _focusNodeBookName,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (e) => _focusNodeArtUrl.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "书名 | Book name",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  onChanged: (e) {
                    setState(() {
                      _artUrl = e.trim();
                    });
                  },
                  focusNode: _focusNodeArtUrl,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (e) => _focusNodeStart.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "封面链接 | Picture url",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  onChanged: (e) {
                    var val = e.trim();
                    if (val.isNotEmpty) {
                      setState(() {
                        _start = int.parse(val);
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeStart,
                  controller: _startController,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (e) => _focusNodeEnd.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "开始集数 | Start Episode",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  onChanged: (e) {
                    var val = e.trim();
                    if (val.isNotEmpty) {
                      setState(() {
                        _end = int.parse(val);
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeEnd,
                  controller: _endController,
                  onSubmitted: (e) => _post(),
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "结束集数 | End Episode",
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

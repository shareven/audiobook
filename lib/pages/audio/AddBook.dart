import 'package:flutter/material.dart';
import 'package:audiobook/model/book_model.dart';
import 'package:audiobook/utils/LocalStorage.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  bool _enableBtn = false;
  TextEditingController _bookNameController =
      new TextEditingController(text: "");
  TextEditingController _artUrlController = new TextEditingController(text: "");
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
    _bookNameController.dispose();
    _artUrlController.dispose();
    _startController.dispose();
    _endController.dispose();
  }

  Future _post() async {
    int? start = int.tryParse(_startController.text);
    int? end = int.tryParse(_endController.text);
    BookModel book = BookModel(
        _bookNameController.text, _artUrlController.text, start!, end!);
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
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    if (v != null && v.trim().isEmpty) {
                      return "不能为空 | Required";
                    }
                    return null;
                  },
                  focusNode: _focusNodeBookName,
                  controller: _bookNameController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (e) => _focusNodeArtUrl.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "书名 | Book name",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    if (v != null && v.trim().isEmpty) {
                      return "不能为空 | Required";
                    }
                    if (v != null && !v.trim().startsWith("http")) {
                      return "需http开头 | Must start with http";
                    }
                    return null;
                  },
                  focusNode: _focusNodeArtUrl,
                  controller: _artUrlController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (e) => _focusNodeStart.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "封面链接 | Picture url",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是正整数 | Must positive integer";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeStart,
                  controller: _startController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (e) => _focusNodeEnd.requestFocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "开始集数 | Start Episode",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是正整数 | Must positive integer";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeEnd,
                  controller: _endController,
                  onFieldSubmitted: (e) => _enableBtn ? _post() : null,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "结束集数 | End Episode",
                  ),
                ),
              ),
              TextWidget(),
            ],
          ),
        ));
  }

  Widget TextWidget() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "命名规则 | Naming convention",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "`书名`（目录名）/`书名`+`集数`+.m4a(文件名)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "`Book name` (directory name) / `Book name` + `Episode number` + .m4a (file name)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "例如 | For example:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传1.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传2.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传3.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

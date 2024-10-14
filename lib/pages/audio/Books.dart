import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:audiobook/config/Global.dart';
import 'package:audiobook/model/book_model.dart';
import 'package:audiobook/pages/audio/AddBook.dart';
import 'package:audiobook/provide/audio_provide.dart';
import 'package:audiobook/utils/LocalStorage.dart';
import 'package:audiobook/widgets/EmptyImage.dart';

class Books extends StatefulWidget {
  const Books({super.key});
  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  DismissDirection _dismissDirection = DismissDirection.endToStart;
  List<BookModel>? _books;
  BookModel? _currentBook;
  @override
  void initState() {
    super.initState();
    _getBookData();
  }

  Future _getBookData() async {
    List<BookModel> books = await LocalStorage.getBooksVal();
    BookModel? book = await LocalStorage.getCurrentBookVal();
    books.insertAll(0, Global.books);
    setState(() {
      _books = books;
      _currentBook = book;
    });
  }

  _setCurrentBook(book) async {
    setState(() {
      _currentBook = book;
    });
    await LocalStorage.setCurrentBookVal(book);
    await LocalStorage.setPlayRecordVal([0, 0]);
  }

  void handleUndo(BookModel item, int insertionIndex) {
    setState(() {
      _books?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(BookModel item) {
    final int insertionIndex = _books!.indexOf(item);
    setState(() {
      _books!.remove(item);
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定删除以下书|Delete it?\n\n${item.name}',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          TextButton(
            child:
                const Text("取消|Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () {
              handleUndo(item, insertionIndex);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child:
                const Text("删除|Delete", style: TextStyle(color: Colors.pink)),
            onPressed: () {
              _deleteBook(item);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future _deleteBook(BookModel book) async {
    if (_currentBook != null && _currentBook!.name == book.name) {
      LocalStorage.setCurrentBookVal(Global.books[0]);
      LocalStorage.setPlayRecordVal([0, 0]);
      setState(() {
        _currentBook = Global.books[0];
      });
    }
    List<BookModel> books = await LocalStorage.getBooksVal();
    books.removeWhere((e) => e.name == book.name);
    List list = books.map((e) => e.toJson()).toList();
    LocalStorage.setBooksVal(list);
    books.insertAll(0, Global.books);
    setState(() {
      _books = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("书 | Books"),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AddBook()));
                _getBookData();
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: _books == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _books!.isEmpty
              ? Center(
                  child: Text("暂无数据|No data"),
                )
              : ListView(
                  children: _books!
                      .map((e) => _LeaveBehindListItem(
                          dismissDirection: _dismissDirection,
                          item: e,
                          currentBook: _currentBook,
                          onTap: (val) async {
                            await _setCurrentBook(e);
                            Provider.of<AudioProvide>(context, listen: false)
                                .setPlayBookItems();
                          },
                          onDelete: _deleteBook))
                      .toList(),
                ),
    );
  }
}

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    Key? key,
    required this.item,
    required this.currentBook,
    required this.onDelete,
    required this.onTap,
    required this.dismissDirection,
  }) : super(key: key);

  final BookModel item;
  final BookModel? currentBook;
  final DismissDirection dismissDirection;
  final void Function(BookModel) onDelete;
  final void Function(BookModel) onTap;

  void _handleDelete() {
    onDelete(item);
  }

  void _handleTap() {
    onTap(item);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
        customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
          // const CustomSemanticsAction(label: '完成'): _handleDelete,
          const CustomSemanticsAction(label: '删除|Delete'): _handleDelete,
        },
        child: Dismissible(
          key: ObjectKey(item),
          direction: dismissDirection,
          onDismissed: (DismissDirection direction) {
            _handleDelete();
          },
          background: Container(
              color: theme.primaryColor,
              child: const ListTile(
                  trailing: Icon(Icons.add, color: Colors.white, size: 36.0))),
          secondaryBackground: Container(
              color: Colors.pink,
              child: const ListTile(
                  contentPadding: EdgeInsets.all(14.0),
                  trailing:
                      Icon(Icons.delete, color: Colors.white, size: 36.0))),
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                  color: theme.canvasColor,
                  border:
                      Border(bottom: BorderSide(color: theme.dividerColor))),
              child: ListTile(
                onTap: _handleTap,
                title: Text(
                  "${item.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("${item.start}-${item.end}集 | Episode"),
                selected: item.name == currentBook?.name,
                selectedColor: Global.themeColor,
                leading: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  imageUrl: '${item.artUrl}',
                  errorWidget: (context, url, error) => EmptyImage(
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

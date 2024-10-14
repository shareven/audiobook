import 'package:flutter/material.dart';

class EmptyImage extends StatelessWidget {
  EmptyImage({this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 35.0,
      height: size ?? 35.0,
      color: Theme.of(context).highlightColor,
    );
  }
}

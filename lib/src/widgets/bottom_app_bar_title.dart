import 'package:flutter/material.dart';

class BottomAppBarTitle extends StatelessWidget {
  final String text;

  const BottomAppBarTitle(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

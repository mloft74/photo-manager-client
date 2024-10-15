import 'package:flutter/material.dart';

const _listViewBasePaddingValue = 16.0;
const edgeInsetsForRoutePadding = EdgeInsets.fromLTRB(
  _listViewBasePaddingValue,
  _listViewBasePaddingValue,
  _listViewBasePaddingValue,
  _listViewBasePaddingValue * 4.0,
);

const maxCrossAxisExtent = 256.0;
const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: maxCrossAxisExtent,
  mainAxisSpacing: 8.0,
  crossAxisSpacing: 8.0,
);

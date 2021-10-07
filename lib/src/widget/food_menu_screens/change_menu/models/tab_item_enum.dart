import 'package:flutter/material.dart';

enum TabItem {
  suggest,
  recently,
  favorite,
  category,
}

extension TabItemDetail on TabItem {
  int get tabIndex {
    switch (this) {
      case TabItem.suggest:
        return 0;
      case TabItem.recently:
        return 1;
      case TabItem.favorite:
        return 2;
      case TabItem.category:
        return 3;
      default:
        return -1;
    }
  }

  String get title {
    switch (this) {
      case TabItem.suggest:
        return 'Món được gợi ý';
      case TabItem.recently:
        return 'Món gần đây';
      case TabItem.favorite:
        return 'Món yêu thích';
      case TabItem.category:
        return 'Danh mục';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';

enum TabItem {
  suggest,
  recently,
  favorite,
  category,
}

extension TabItemDetail on TabItem {
  Widget get tab {
    switch (this) {
      case TabItem.suggest:
        //TODO: Tuyen add SuggestFoodWidget
        return Container(color: Colors.red);
      case TabItem.recently:
        //TODO: Tuyen add RecentlyFoodWidget
        return Container(color: Colors.blue);
      case TabItem.favorite:
        //TODO: Tuyen add FavoriteFoodWidget
        return Container(color: Colors.orange);
      case TabItem.category:
        //TODO: Tuyen add CategoryFoodWidget
        return Container(color: Colors.green);
      default:
        return Container();
    }
  }

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

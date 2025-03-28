enum TabBarType {
  home,
  program,
  library,
  chat,
  store,
}

extension TabBarTypeExt on TabBarType {
  String get title {
    switch (this) {
      // TODO: localize
      case TabBarType.home:
        return 'Trang chủ';
      case TabBarType.program:
        return 'Chương trình';
      case TabBarType.library:
        return 'Thư viện';
      case TabBarType.chat:
        return 'Hỏi đáp';
      case TabBarType.store:
        return 'Cửa hàng';
    }
  }

  String get iconPath {
    switch (this) {
      case TabBarType.home:
        return 'lib/res/drawables/tab/ic_tab_home.png';
      case TabBarType.program:
        return 'lib/res/drawables/tab/ic_tab_program.png';
      case TabBarType.library:
        return 'lib/res/drawables/tab/ic_tab_library.png';
      case TabBarType.chat:
        return 'lib/res/drawables/tab/ic_tab_faq.png';
      case TabBarType.store:
        return 'lib/res/drawables/tab/ic_tab_store_new.png';
    }
  }

  int get index {
    switch (this) {
      case TabBarType.home:
        return 0;
      case TabBarType.program:
        return 1;
      case TabBarType.library:
        return 2;
      case TabBarType.chat:
        return 3;
      case TabBarType.store:
        return 4;
    }
  }
}
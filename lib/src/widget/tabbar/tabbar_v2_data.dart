enum MainTabEnum {
  home,
  program,
  library,
  faq,
  store,
}

extension MainTabEnum_ on MainTabEnum {
  String get title {
    switch (this) {
      // TODO: localize
      case MainTabEnum.home:
        return 'Trang chủ';
      case MainTabEnum.program:
        return 'Chương trình';
      case MainTabEnum.library:
        return 'Thư viện';
      case MainTabEnum.faq:
        return 'Hỏi đáp';
      case MainTabEnum.store:
        return 'Cửa hàng';
    }
  }

  String get icon {
    switch (this) {
      case MainTabEnum.home:
        return 'ic_home';
      case MainTabEnum.program:
        return 'ic_plan';
      case MainTabEnum.library:
        return 'ic_qa';
      case MainTabEnum.faq:
        return 'ic_home_store';
      case MainTabEnum.store:
        return 'ic_home_store';
    }
  }

  int get index {
    switch (this) {
      case MainTabEnum.home:
        return 0;
      case MainTabEnum.program:
        return 1;
      case MainTabEnum.library:
        return 2;
      case MainTabEnum.faq:
        return 3;
      case MainTabEnum.store:
        return 4;
    }
  }
}
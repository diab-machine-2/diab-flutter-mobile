import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

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
      case TabBarType.home:
        return R.string.tab_home.tr();
      case TabBarType.program:
        return R.string.program.tr();
      case TabBarType.library:
        return R.string.profile_gallery.tr();
      case TabBarType.chat:
        return R.string.q_and_a.tr();
      case TabBarType.store:
        return R.string.store.tr();
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
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

abstract class BaseState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void didPush() {}

  @override
  void didPopNext() {}

  @override
  void didPop() {
    BotToast.closeAllLoading();
  }

  @override
  void didPushNext() {}

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    BotToast.closeAllLoading();
    super.dispose();
  }
}

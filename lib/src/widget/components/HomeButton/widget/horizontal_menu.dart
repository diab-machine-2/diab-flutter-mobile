import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Wrapper that builds a FAB menu on top of [body] in a [Stack]
class HorizontalMenu extends StatefulWidget {
  final Widget body;
  final List<HorizontalMenuItem> items;
  final double blur;
  // final AnimatedIconData? icon;
  final IconData? icon;
  final Color? fabColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? heroTag;

  HorizontalMenu({
    Key? key,
    required this.body,
    required this.items,
    this.blur = 5.0,
    //  this.icon,
    this.fabColor,
    this.iconColor,
    this.backgroundColor,
    this.icon,
    this.heroTag,
  }) : super(key: key) {
    assert(items.isNotEmpty);
  }

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> with TickerProviderStateMixin {
  /// To check if the menu is open
  bool _isOpen = true;

  /// The [Duration] for every animation
  final Duration _duration = const Duration(milliseconds: 500);

  /// Animation controller that animates the menu item
  late AnimationController _iconAnimationCtrl;

  /// Animation that animates the menu item
  late Animation<double> _iconAnimationTween;

  @override
  void initState() {
    super.initState();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_iconAnimationCtrl);
  }

  /// Closes the menu if open and vice versa
  // void _toggleMenu() {
  //   setState(() {
  //     _isOpen = !_isOpen;
  //   });
  //   if (_isOpen) {
  //     _iconAnimationCtrl.forward();
  //   } else {
  //     _iconAnimationCtrl.reverse();
  //   }
  // }

  void _toggleCancel() {
    Navigator.pop(context);
  }

  /// If the menu is open and the device's back button is pressed then menu gets closed instead of going back.
  Future<bool> _preventPopIfOpen() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          widget.body,
          _isOpen ? _buildBlurWidget() : Container(),
          _isOpen ? _buildMenuItemList() : Container(),
          _buildMenuButton(context),
        ],
      ),
      onWillPop: _preventPopIfOpen,
    );
  }

  /// Returns animated list of menu items
  Widget _buildMenuItemList() {
    return Positioned(
      bottom: 100,
      left: 40,
      child: ScaleTransition(
        scale: AnimationController(
          vsync: this,
          value: 0.7,
          duration: _duration,
        )..forward(),
        child: SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: AnimationController(
            vsync: this,
            value: 0.5,
            duration: _duration,
          )..forward(),
          child: FadeTransition(
            opacity: AnimationController(
              vsync: this,
              value: 0.0,
              duration: _duration,
            )..forward(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items
                  .map<Widget>(
                    (item) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItemWidget(
                          item: item,
                          toggleMenu: _toggleCancel,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the blur effect when the menu is opened
  Widget _buildBlurWidget() {
    return InkWell(
      onTap: _toggleCancel,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          color: widget.backgroundColor ?? Colors.black12,
        ),
      ),
    );
  }

  /// Builds the main floating action button of the menu to the bottom right
  /// On clicking of which the menu toggles
  Widget _buildMenuButton(BuildContext context) {
    late Widget iconWidget;
    iconWidget = Icon(
      widget.icon,
      color: widget.iconColor,
    );

    return Positioned(
      bottom: 34,
      left: MediaQuery.of(context).size.width / 2 - 28,
      child: FloatingActionButton(
        child: iconWidget,
        heroTag: widget.heroTag ?? '_HawkFabMenu_$hashCode',
        backgroundColor: widget.fabColor ?? Theme.of(context).primaryColor,
        onPressed: _toggleCancel,
      ),
    );
  }
}

/// Builds widget for a single menu item
class _MenuItemWidget extends StatelessWidget {
  /// Contains details for a single menu item
  final HorizontalMenuItem item;

  /// A callback that toggles the menu
  final Function toggleMenu;

  const _MenuItemWidget({
    required this.item,
    required this.toggleMenu,
  });

  /// Closes the menu and calls the function for a particular menu item
  void onTap() {
    toggleMenu();
    item.ontap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: onTap,
            heroTag: item.heroTag ?? '_MenuItemWidget_$hashCode',
            child: item.icon,
            backgroundColor: item.color ?? Theme.of(context).primaryColor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: item.labelBackgroundColor ?? Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(
              item.label,
              style: TextStyle(color: item.labelColor ?? Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for single menu item
class HorizontalMenuItem {
  /// Text label for for the menu item
  String label;

  /// Corresponding icon for the menu item
  Widget icon;

  /// Action that is to be performed on tapping the menu item
  Function ontap;

  /// Background color for icon
  Color? color;

  /// Text color for label
  Color? labelColor;

  /// Background color for label
  Color? labelBackgroundColor;

  /// The tag to apply to the button's [Hero] widget.
  String? heroTag;

  HorizontalMenuItem({
    required this.label,
    required this.ontap,
    required this.icon,
    this.color,
    this.labelBackgroundColor,
    this.labelColor,
    this.heroTag,
  });
}

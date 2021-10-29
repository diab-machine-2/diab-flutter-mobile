import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tags/src/tags.dart';
import 'package:medical/res/R.dart';

/// Used by [ItemTags.onPressed].
typedef OnPressedCallback = void Function(Item i);

/// Used by [ItemTags.OnLongPressed].
typedef OnLongPressedCallback = void Function(Item i);

/// Used by [ItemTags.removeButton.onRemoved].
typedef OnRemovedCallback = bool Function();

/// combines icon text or image
enum ItemTagsCustomCombine {
  onlyText,
  onlyIcon,
  onlyImage,
  imageOrIconOrText,
  withTextBefore,
  withTextAfter
}

class ItemTagsCustom extends StatefulWidget {
  ItemTagsCustom(
      {required this.index,
      required this.title,
      this.textScaleFactor,
      this.active = true,
      this.pressEnabled = true,
      this.customData,
      this.textStyle = const TextStyle(fontSize: 14),
      this.alignment = MainAxisAlignment.center,
      this.combine = ItemTagsCustomCombine.imageOrIconOrText,
      this.icon,
      this.image,
      this.removeButton,
      this.borderRadius,
      this.border,
      this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      this.elevation = 5,
      this.singleItem = false,
      this.textOverflow = TextOverflow.fade,
      this.textColor = Colors.black,
      this.textActiveColor = Colors.white,
      this.color = Colors.white,
      this.activeColor = Colors.blueGrey,
      this.highlightColor,
      this.splashColor,
      this.colorShowDuplicate = Colors.red,
      this.onPressed,
      this.onLongPressed,
      Key? key})
      : assert(index != null),
        assert(title != null),
        super(key: key);

  /// Id of [ItemTags] - required
  final int index;

  /// Title of [ItemTags] - required
  final String title;

  /// Scale Factor of [ItemTags] - double
  final double? textScaleFactor;

  /// Initial bool value
  final bool active;

  /// Initial bool value
  final bool pressEnabled;

  /// Possibility to add any custom value in customData field, you can retrieve this later. A good example: store an id from Firestore document.
  final dynamic customData;

  /// ItemTagsCombine (text,icon,textIcon,textImage) of [ItemTags]
  final ItemTagsCustomCombine combine;

  /// Icon of [ItemTags]
  final ItemTagsCustomIcon? icon;

  /// Image of [ItemTagsCustom]
  final ItemTagsCustomImage? image;

  /// Custom Remove Button of [ItemTagsCustom]
  final ItemTagsCustomRemoveButton? removeButton;

  /// TextStyle of the [ItemTagsCustom]
  final TextStyle textStyle;

  /// TextStyle of the [ItemTagsCustom]
  final MainAxisAlignment alignment;

  /// border-radius of [ItemTagsCustom]
  final BorderRadius? borderRadius;

  /// custom border-side of [ItemTagsCustom]
  final BoxBorder? border;

  /// padding of the [ItemTagsCustom]
  final EdgeInsets padding;

  /// BoxShadow of the [ItemTagsCustom]
  final double elevation;

  /// when you want only one tag selected. same radio-button
  final bool singleItem;

  /// type of text overflow within the [ItemTagsCustom]
  final TextOverflow textOverflow;

  /// text color of the [ItemTagsCustom]
  final Color textColor;

  /// color of the [ItemTagsCustom] text activated
  final Color textActiveColor;

  /// background color [ItemTagsCustom]
  final Color color;

  /// background color [ItemTagsCustom] activated
  final Color activeColor;

  /// highlight Color [ItemTagsCustom]
  final Color? highlightColor;

  /// Splash color [ItemTagsCustom]
  final Color? splashColor;

  /// Color show duplicate [ItemTagsCustom]
  final Color colorShowDuplicate;

  /// callback
  final OnPressedCallback? onPressed;

  /// callback
  final OnLongPressedCallback? onLongPressed;

  @override
  _ItemTagsCustomState createState() => _ItemTagsCustomState();
}

class _ItemTagsCustomState extends State<ItemTagsCustom> {
  final double _initBorderRadius = 50;

  DataListInherited? _dataListInherited;
  DataList? _dataList;

  void _setDataList() {
    // Get List<DataList> from Tags widget
    _dataListInherited = DataListInherited.of(context);

    // set List length
    if (_dataListInherited!.list!.length < _dataListInherited!.itemCount!)
      _dataListInherited!.list!.length = _dataListInherited!.itemCount!;

    if (_dataListInherited!.list!.length > (widget.index + 1) &&
        _dataListInherited!.list!.elementAt(widget.index) != null &&
        _dataListInherited!.list!.elementAt(widget.index)?.title != widget.title) {
      // when an element is removed from the data source
      _dataListInherited!.list!.removeAt(widget.index);

      // when all item list changed in data source
      if (_dataListInherited!.list!.elementAt(widget.index) != null &&
          _dataListInherited!.list!.elementAt(widget.index)?.title != widget.title)
        _dataListInherited!.list!
            .removeRange(widget.index, _dataListInherited!.list!.length);
    }

    // add new Item in the List
    if (_dataListInherited!.list!.length < (widget.index + 1)) {
      //print("add");
      _dataListInherited!.list!.insert(
          widget.index,
          DataList(
              title: widget.title,
              index: widget.index,
              active: widget.singleItem ? false : widget.active,
              customData: widget.customData));
    } else if (_dataListInherited!.list!.elementAt(widget.index) == null) {
      //print("replace");
      _dataListInherited!.list![widget.index] = DataList(
          title: widget.title,
          index: widget.index,
          active: widget.singleItem ? false : widget.active,
          customData: widget.customData);
    }

    // removes items that have been orphaned
    if (_dataListInherited!.itemCount == widget.index + 1 &&
        _dataListInherited!.list!.length > _dataListInherited!.itemCount!)
      _dataListInherited!.list!
          .removeRange(widget.index + 1, _dataListInherited!.list!.length);

    //print(_dataListInherited.list.length);

    // update Listener
    if (_dataList != null) _dataList!.removeListener(_didValueChange);

    _dataList = _dataListInherited!.list!.elementAt(widget.index);
    _dataList!.addListener(_didValueChange);
  }

  _didValueChange() => setState(() {});

  @override
  void dispose() {
    _dataList!.removeListener(_didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setDataList();

    final double fontSize = widget.textStyle.fontSize!;

    Color color = _dataList!.active ? widget.activeColor : widget.color;

    if (_dataList!.showDuplicate) color = widget.colorShowDuplicate;

    return Material(
      color: color,
      borderRadius:
          widget.borderRadius ?? BorderRadius.circular(_initBorderRadius),
      elevation: widget.elevation,
      child: InkWell(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(_initBorderRadius),
        highlightColor:
            widget.pressEnabled ? widget.highlightColor : R.color.transparent,
        splashColor:
            widget.pressEnabled ? widget.splashColor : R.color.transparent,
        child: Container(
            decoration: BoxDecoration(
                border: widget.border ??
                    Border.all(color: widget.activeColor, width: 0.5),
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(_initBorderRadius)),
            padding: widget.padding * (fontSize / 100),
            child: _combine),
        onTap: widget.pressEnabled
            ? () {
                if (widget.singleItem) {
                  _singleItem(_dataListInherited!, _dataList);
                  _dataList!.active = true;
                } else
                  _dataList!.active = !_dataList!.active;

                if (widget.onPressed != null)
                  widget.onPressed!(Item(
                      index: widget.index,
                      title: _dataList!.title,
                      active: _dataList!.active,
                      customData: widget.customData));
              }
            : null,
        onLongPress: widget.onLongPressed != null
            ? () => widget.onLongPressed!(Item(
                index: widget.index,
                title: _dataList!.title,
                active: _dataList!.active,
                customData: widget.customData))
            : null,
      ),
    );
  }

  Widget get _combine {
    if (widget.image != null)
      assert((widget.image!.image != null && widget.image!.child == null) ||
          (widget.image!.child != null && widget.image!.image == null));

    final Widget text = Text(
      widget.title,
      softWrap: false,
      textAlign: _textAlignment,
      overflow: widget.textOverflow,
      textScaleFactor: widget.textScaleFactor,
      style: _textStyle,
    );
    final Widget icon = widget.icon != null
        ? Container(
            padding: widget.icon!.padding ??
                (widget.combine == ItemTagsCustomCombine.onlyIcon ||
                        widget.combine ==
                            ItemTagsCustomCombine.imageOrIconOrText
                    ? null
                    : widget.combine == ItemTagsCustomCombine.withTextAfter
                        ? EdgeInsets.only(right: 5)
                        : EdgeInsets.only(left: 5)),
            child: Icon(
              widget.icon!.icon,
              color: _textStyle.color,
              size: _textStyle.fontSize! * 1.2,
            ),
          )
        : text;
    final Widget image = widget.image != null
        ? Column(
            children: [
              Container(
                padding: widget.image!.padding ??
                    (widget.combine == ItemTagsCustomCombine.onlyImage ||
                            widget.combine ==
                                ItemTagsCustomCombine.imageOrIconOrText
                        ? null
                        : widget.combine == ItemTagsCustomCombine.withTextAfter
                            ? EdgeInsets.only(right: 10)
                            : EdgeInsets.only(left: 10)),
                child: widget.image!.child ??
                    CircleAvatar(
                      radius: widget.image!.radius *
                          (widget.textStyle.fontSize! / 14),
                      backgroundColor: R.color.transparent,
                      backgroundImage: widget.image!.image,
                    ),
              ),
              SizedBox(height: 10),
              Text(
                widget.title,
                softWrap: false,
                textAlign: _textAlignment,
                overflow: widget.textOverflow,
                textScaleFactor: widget.textScaleFactor,
                style: _textStyle,
              ),
            ],
          )
        : text;

    final List list = [];

    switch (widget.combine) {
      case ItemTagsCustomCombine.onlyText:
        list.add(text);
        break;
      case ItemTagsCustomCombine.onlyIcon:
        list.add(icon);
        break;
      case ItemTagsCustomCombine.onlyImage:
        list.add(image);
        break;
      case ItemTagsCustomCombine.imageOrIconOrText:
        list.add((image != text ? image : icon));
        break;
      case ItemTagsCustomCombine.withTextBefore:
        list.add(text);
        if (image != text)
          list.add(image);
        else if (icon != text) list.add(icon);
        break;
      case ItemTagsCustomCombine.withTextAfter:
        if (image != text)
          list.add(image);
        else if (icon != text) list.add(icon);
        list.add(text);
    }

    final Widget row = Row(
        mainAxisAlignment: widget.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(list.length, (i) {
          if (i == 0 && list.length > 1)
            return Flexible(
              flex:
                  widget.combine == ItemTagsCustomCombine.withTextAfter ? 0 : 1,
              child: list[i],
            );
          return Flexible(
            flex: widget.combine == ItemTagsCustomCombine.withTextAfter ||
                    list.length == 1
                ? 1
                : 0,
            child: list[i],
          );
        }));

    if (widget.removeButton != null)
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
                fit:
                    _dataListInherited!.symmetry! ? FlexFit.tight : FlexFit.loose,
                flex: 2,
                child: row),
            Flexible(
                flex: 0,
                child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.fill,
                    child: GestureDetector(
                      child: Container(
                        margin: widget.removeButton!.margin ??
                            EdgeInsets.only(left: 5),
                        padding:
                            (widget.removeButton!.padding ?? EdgeInsets.all(2)) *
                                (widget.textStyle.fontSize! / 14),
                        decoration: BoxDecoration(
                          color: widget.removeButton!.backgroundColor ??
                              R.color.black,
                          borderRadius: widget.removeButton!.borderRadius ??
                              BorderRadius.circular(_initBorderRadius),
                        ),
                        child: widget.removeButton!.padding as Widget? ??
                            Icon(
                              Icons.clear,
                              color: widget.removeButton!.color ?? R.color.white,
                              size: (widget.removeButton!.size ?? 12) *
                                  (widget.textStyle.fontSize! / 14),
                            ),
                      ),
                      onTap: () {
                        if (widget.removeButton!.onRemoved != null) {
                          if (widget.removeButton!.onRemoved!())
                            _dataListInherited!.list!.removeAt(widget.index);
                        }
                      },
                    )))
          ]);

    return row;
  }

  ///Text Alignment
  TextAlign? get _textAlignment {
    switch (widget.alignment) {
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.start:
        return TextAlign.start;
        break;
      case MainAxisAlignment.end:
        return TextAlign.end;
        break;
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceEvenly:
      case MainAxisAlignment.center:
        return TextAlign.center;
    }
    return null;
  }

  ///TextStyle
  TextStyle get _textStyle {
    return widget.textStyle.apply(
      color: _dataList!.active ? widget.textActiveColor : widget.textColor,
    );
  }

  /// Single item selection
  void _singleItem(DataListInherited dataSetIn, DataList? dataSet) {
    dataSetIn.list!
        .where((tg) => tg != null)
        .where((tg) => tg?.active ?? false)
        .where((tg2) => tg2 != dataSet)
        .forEach((tg) => tg?.active = false);
  }
}

///callback
class Item {
  Item({this.index, this.title, this.active, this.customData});
  final int? index;
  final String? title;
  final bool? active;
  final dynamic customData;

  @override
  String toString() {
    return "id:$index, title: $title, active: $active, customData: $customData";
  }
}

/// ItemTag Image
class ItemTagsCustomImage {
  ItemTagsCustomImage({this.radius = 8, this.padding, this.image, this.child});

  final double radius;
  final EdgeInsets? padding;
  final ImageProvider? image;
  final Widget? child;
}

/// ItemTag Icon
class ItemTagsCustomIcon {
  ItemTagsCustomIcon({this.padding, required this.icon});

  final EdgeInsets? padding;
  final IconData icon;
}

/// ItemTag RemoveButton
class ItemTagsCustomRemoveButton {
  ItemTagsCustomRemoveButton(
      {this.icon,
      this.size,
      this.backgroundColor,
      this.color,
      this.borderRadius,
      this.padding,
      this.margin,
      this.onRemoved});

  final IconData? icon;
  final double? size;
  final Color? backgroundColor;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  /// callback
  final OnRemovedCallback? onRemoved;
}

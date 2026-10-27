import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';

/// Records the cart notifications FoodItem sends when it has no local
/// onSelectionChanged callback (e.g. the "Tất cả" tab).
class _CartSpy with Observer {
  final List<String> names = [];

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if (notifyName == 'add_food_to_cart' ||
        notifyName == 'remove_food_from_cart') {
      names.add(notifyName!);
    }
  }
}

Widget _host(FoodItem item) => MaterialApp(home: Scaffold(body: item));

FoodItem _item({FoodModel? selected, FoodSelectionCallback? onSelection}) =>
    FoodItem(
      model: FoodModel(id: 'f1', name: 'Phở', unit: 'Tô', calorie: 200),
      selectedModel: selected,
      index: 0,
      isSearch: true,
      callback: (_, __) {},
      kcalLeft: null,
      onSelectionChanged: onSelection,
    );

// The checkbox is the only 24x24 box with a border in the row.
Finder _checkbox() => find.byWidgetPredicate((w) =>
    w is Container &&
    w.constraints?.maxWidth == 24 &&
    w.constraints?.maxHeight == 24);

void main() {
  late _CartSpy spy;

  setUp(() {
    spy = _CartSpy();
    Observable.instance.addObserver(spy);
  });

  tearDown(() => Observable.instance.removeObserver(spy));

  testWidgets('checkbox adds the food when no local callback is passed',
      (tester) async {
    await tester.pumpWidget(_host(_item()));
    await tester.tap(_checkbox());
    expect(spy.names, ['add_food_to_cart']);
  });

  testWidgets('checkbox removes an already selected food', (tester) async {
    await tester.pumpWidget(_host(_item(
        selected: FoodModel(id: 'f1', name: 'Phở', unit: 'Tô', calorie: 200))));
    await tester.tap(_checkbox());
    expect(spy.names, ['remove_food_from_cart']);
  });

  testWidgets('checkbox uses the local callback when provided',
      (tester) async {
    bool? toggledTo;
    await tester.pumpWidget(
        _host(_item(onSelection: (_, selected) => toggledTo = selected)));
    await tester.tap(_checkbox());
    expect(toggledTo, isTrue);
    expect(spy.names, isEmpty);
  });
}

import 'package:flutter/material.dart';
import 'package:medical/src/theme/app_theme.dart';

class CustomDropDown extends StatelessWidget {
  final name;
  final value;
  final List<String> itemsList;
  final Color dropdownColor;
  final Function(dynamic value) onChanged;
  const CustomDropDown({
    @required this.name,
    @required this.value,
    @required this.itemsList,
    this.dropdownColor,
    @required this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(name, style: TextStyle(color: textDark)),
                Text(" *", style: TextStyle(color: Colors.red))
              ],
            )),
        Padding(
          padding: EdgeInsets.only(left: 2, top: 10, bottom: 6, right: 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 14.0, right: 14, top: 2, bottom: 2),
                child: DropdownButton(
                  isExpanded: true,
                  dropdownColor: dropdownColor,
                  value: value,
                  items: itemsList
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) => onChanged(value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

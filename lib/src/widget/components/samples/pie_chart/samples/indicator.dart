
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color? color;
  final String? text;
  final bool? isSquare;
  final double? size;
  final Color? textColor;
  final String? number;

  const Indicator({
    Key? key,
    this.color,
    this.text,
    this.isSquare,
    this.size,
    this.number,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        //  Container(
        //     width: size,
        //     height: size,
        //     decoration: BoxDecoration(
        //       shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        //       color: color,
        //     ),
        //     child: Text(number),
        //   ),
        //   const SizedBox(
        //     width: 4,
        //   ),
        //   Text(
        //     text,
        //     style: TextStyle(
        //         fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        //   )
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              SizedBox(
                width: 67,
                child: Row(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            shape:
                                isSquare! ? BoxShape.rectangle : BoxShape.circle,
                            color: color,
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 2, bottom: 2, left: 8, right: 8),
                          child: Center(
                            child: Text(number!,
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    fontSize: 16,
                                    color: textColor,
                                    fontWeight: FontWeight.w400)),
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(width: 4),
              Text(text!, style: TextStyle(fontSize: 13))
            ],
          ),
        )
      ],
    );
  }
}

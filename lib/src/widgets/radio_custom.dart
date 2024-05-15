import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadioCustom extends StatelessWidget {
  final bool isSelected;
  const RadioCustom({Key? key, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4BB2AB),
                  Color(0xFF01857A),
                  Color(0xFF008479)
                ],
              )
            : null,
        border: Border.all(
          width: isSelected ? 0 : 1,
          color: isSelected ? Colors.transparent : Color(0xFFB3B7BC),
        ),
      ),
      child: Center(
        child: Container(
          width: isSelected ? 9 : 0,
          height: isSelected ? 9 : 0,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

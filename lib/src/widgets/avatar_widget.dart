import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class AvatarWidget extends StatelessWidget{

  final String? name;
  final String? avatar;
  final double size;

  const AvatarWidget({Key? key, this.name, this.avatar, required this.size}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Avatar(
      name: name?.toUpperCase() ?? "",
      shape: AvatarShape.circle(size),
      useCache: true,
      placeholderColors: const [
        Color(0xFF6FD4FC),
        Color(0xFF2B9EF0),
      ],
      textStyle: TextStyle(
          color: R.color.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
      ),
      sources: [NetworkSource(avatar ?? "")],
    );
  }
}

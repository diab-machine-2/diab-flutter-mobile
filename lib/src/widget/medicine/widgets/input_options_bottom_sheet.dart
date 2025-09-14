import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../res/R.dart';

class InputOptionsBottomSheet extends StatelessWidget {
  final VoidCallback? onCameraTap;
  final VoidCallback? onHandTap;

  const InputOptionsBottomSheet({
    Key? key,
    this.onCameraTap,
    this.onHandTap,
  }) : super(key: key);

  static Future<void> show(BuildContext context,
      {VoidCallback? onCameraTap, VoidCallback? onHandTap}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return InputOptionsBottomSheet(
          onCameraTap: onCameraTap,
          onHandTap: onHandTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            R.string.input_options.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          InputOptionItem(
            icon: R.drawable.ic_input_by_camera,
            title: R.string.input_by_camera.tr(),
            description: R.string.input_by_camera_description.tr(),
            onTap: () {
              Navigator.pop(context);
              onCameraTap?.call();
            },
          ),
          const SizedBox(height: 16),
          InputOptionItem(
            icon: R.drawable.ic_input_by_hand,
            title: R.string.input_by_hand.tr(),
            description: R.string.input_by_hand_description.tr(),
            onTap: () {
              Navigator.pop(context);
              onHandTap?.call();
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class InputOptionItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const InputOptionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 126,
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 72, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111515),
                      )),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff5E6566),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, size: 24),
          ],
        ),
      ),
    );
  }
}

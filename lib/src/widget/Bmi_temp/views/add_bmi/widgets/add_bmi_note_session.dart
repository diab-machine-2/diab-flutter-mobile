
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi/widgets/bmi_input_images_list_view.dart';

class AddBmiNoteSession extends StatelessWidget {
  const AddBmiNoteSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.ghi_chu.tr(),
            style: R.style.boldXLargeStyle,
          ),
          const _NoteInputTextField(),
          const BmiInputImagesListView()
        ],
      ),
    );
  }
}

class _NoteInputTextField extends StatefulWidget {
  const _NoteInputTextField({
    super.key,
  });

  @override
  State<_NoteInputTextField> createState() => _NoteInputTextFieldState();
}

class _NoteInputTextFieldState extends State<_NoteInputTextField> {
  final TextEditingController _controller = TextEditingController();
  final int maxLength = 250;

  static const _border =
      UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral5));
  late BmiInputBloc _bmiInputBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
        hintStyle: R.style.normalTextStyle.copyWith(color: AppColors.neutral4),
        focusedBorder: _border,
        enabledBorder: _border,
        suffixIcon: GestureDetector(
          onTap: _pickImages,
          child: Icon(
            Icons.photo_rounded,
            color: R.color.mainColor,
          ),
        ),
        counterText: "${_controller.text.length} / $maxLength",
        counterStyle:
            R.style.smallTextStyle.copyWith(color: AppColors.neutral4),
      ),
      style: R.style.normalTextStyle,
      controller: _controller,
      onChanged: (value) => _bmiInputBloc.note = value,
    );
  }

  void _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage(
      // maxWidth: 1024,
      // maxHeight: 1024,
      imageQuality: 70,
    );

    _bmiInputBloc.addImages(images.map((e) => e.path).toList());
  }
}

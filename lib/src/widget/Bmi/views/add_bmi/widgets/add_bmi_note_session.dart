import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/bmi_input_images_list_view.dart';

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
    return BlocListener<BmiInputBloc, BmiInputState>(
      listenWhen: (previous, state) => state is BmiInputDataChangedState,
      listener: (context, state) {
        if (state is BmiInputDataChangedState) {
          if (state.event == BmiInputDataChangeEvent.noteChanged) {
            _controller.text = state.data;
          }
        }
      },
      child: TextField(
        decoration: InputDecoration(
          hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
          hintStyle:
              R.style.normalTextStyle.copyWith(color: AppColors.neutral4),
          focusedBorder: _border,
          enabledBorder: _border,
          suffixIcon: GestureDetector(
            onTap: _pickImages,
            child: Icon(
              Icons.image_outlined,
              color: R.color.mainColor,
            ),
          ),
        ),
        minLines: 1,
        maxLines: null,
        maxLength: maxLength,
        style: R.style.normalTextStyle,
        controller: _controller,
        onChanged: (value) => _bmiInputBloc.note = value,
        buildCounter: (
          BuildContext context, {
          required int currentLength,
          required bool isFocused,
          required int? maxLength,
        }) {
          return Text(
            '$currentLength / $maxLength',
            style: R.style.smallTextStyle.copyWith(color: AppColors.neutral4),
          );
        },
      ),
    );
  }

  void _pickImages() async {
    const int maxImages = 5;
    final int currentImageCount = _bmiInputBloc.noteImages.length +
        _bmiInputBloc.noteImagesFromRecord.length;

    if (currentImageCount >= maxImages) {
      // Show a message that max images reached
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(R.string.max_image_select.tr()),
          ),
        );
      }
      return;
    }

    final int remainingSlots = maxImages - currentImageCount;
    final ImagePicker _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );

    if (images.isEmpty) return;

    // Limit the images to the remaining slots and convert to JPEG format
    final List<XFile> imagesToProcess = images.take(remainingSlots).toList();
    final List<String> imagePaths = [];
    for (final image in imagesToProcess) {
      // Convert image to JPEG format (handles HEIC/HEIF from iOS)
      final convertedPath = await Utils.convertImageToJpeg(image.path);
      imagePaths.add(convertedPath);
    }

    _bmiInputBloc.addImages(imagePaths);

    // Show a message if user selected more than allowed
    if (images.length > remainingSlots && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            R.string.max_image_select.tr(),
          ),
        ),
      );
    }
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

import 'widget/section_add_note.dart';

class PageAddBloodSugarResultNote extends StatefulWidget {
  const PageAddBloodSugarResultNote({super.key, this.note, this.files});
  final String? note;
  final List<dynamic>? files;

  @override
  State<PageAddBloodSugarResultNote> createState() =>
      _PageAddBloodSugarResultNoteState();
}

class _PageAddBloodSugarResultNoteState
    extends State<PageAddBloodSugarResultNote> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controllerNote =
      TextEditingController(text: widget.note);
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: R.color.glucose_bg_color,
        body: Container(
          child: Column(
            children: [
              _appBarSection(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SectionAddNote(
                  focusNode: _focusNode,
                  controllerNote: _controllerNote,
                  maxMedia: 5,
                  key: _sectionAddNoteKey,
                  initialFiles: widget.files,
                  // Images opened from result page should be removable → red circle icon
                  initialFilesFromCamera: false,
                  // Allow deleting existing images in note edit screen
                  showCameraIcons: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        R.string.them_ghi_chu.tr(),
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: R.color.white),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.close, color: R.color.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final note = _sectionAddNoteKey.currentState?.getNote();
            Navigator.pop(context, {
              'note': note?.note,
              'files': note?.files,
              'removeIDs': note?.removeIDs,
            });
          },
          child: Text(
            R.string.luu_ghi_chu.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: R.color.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

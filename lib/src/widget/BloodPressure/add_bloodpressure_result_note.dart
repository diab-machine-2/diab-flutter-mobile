import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class PageAddBloodPressureResultNote extends StatefulWidget {
  const PageAddBloodPressureResultNote({super.key, this.note, this.files});
  final String? note;
  final List<dynamic>? files;

  @override
  State<PageAddBloodPressureResultNote> createState() => _PageAddBloodPressureResultNoteState();
}

class _PageAddBloodPressureResultNoteState extends State<PageAddBloodPressureResultNote> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controllerNote = TextEditingController(text: widget.note);
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();

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
        backgroundColor: R.color.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(R.drawable.bg_splash),
              fit: BoxFit.cover,
            ),
          ),
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
      backgroundColor: R.color.transparent,
      title: Text(
        R.string.them_ghi_chu.tr(),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.close, color: R.color.textDark),
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
              fontWeight: FontWeight.bold,
              color: R.color.mainColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

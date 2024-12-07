import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

import 'widget/section_add_note.dart';

class PageAddBloodSugarResultNote extends StatefulWidget {
  const PageAddBloodSugarResultNote({super.key});

  @override
  State<PageAddBloodSugarResultNote> createState() => _PageAddBloodSugarResultNoteState();
}

class _PageAddBloodSugarResultNoteState extends State<PageAddBloodSugarResultNote> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
            ),
          ],
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
            // TODO: Save note
            Navigator.pop(context);
          },
          child: Text(
            R.string.luu_ghi_chu.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: R.color.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

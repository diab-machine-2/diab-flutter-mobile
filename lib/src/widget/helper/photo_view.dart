import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../widgets/network_image_widget.dart';

class PhotoView extends StatefulWidget {
  final List<dynamic> files;
  final int index;
  PhotoView({required this.files, required this.index});

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    TrackingManager.analytics.setCurrentScreen(screenName: "Picture Preview");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(alignment: AlignmentDirectional.topEnd, children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              Navigator.pop(context);
            },
            child: PageView.builder(
                controller: controller,
                itemCount: widget.files.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget.files[index] is PickedFile
                      ? Image.file(
                          File(widget.files[index].path),
                          fit: BoxFit.fitWidth,
                        )
                      : NetWorkImageWidget(imageUrl: widget.files[index].url,
                          fit: BoxFit.fitWidth);
                }),
          ),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(right: 18),
            child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )),
        ]));
  }
}

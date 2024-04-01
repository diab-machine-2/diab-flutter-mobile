import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:medical/src/utils/api_methods.dart';

import '../../utils/const.dart';

class TestOcrFinalImage extends StatefulWidget {
  final Uint8List bytes;
  final Uint8List? fullImage;
  const TestOcrFinalImage({Key? key, required this.bytes, this.fullImage})
      : super(key: key);

  @override
  _TestOcrFinalImageState createState() => _TestOcrFinalImageState();
}

class _TestOcrFinalImageState extends State<TestOcrFinalImage> {
  @override
  void initState() {
    super.initState();
    // Simulate loading delay
  }

  Future<Map<String, dynamic>?> _sendImageToApi() async {
    BotToast.showLoading();
    BotToast.showNotification(
        title: (cancelFunc) => Text("Quá trình sẽ mất khoản 20-30s"),
        duration: Duration(seconds: 10));
    // Compress the image bytes
    final compressedBytes = await FlutterImageCompress.compressWithList(
      widget.bytes,
      quality: 50, // Adjust quality as needed (0 to 100)
    );
    final compressedFullImage = widget.fullImage != null
        ? await FlutterImageCompress.compressWithList(
            widget.bytes,
            quality: 50,
          )
        : null;

    // if case gallery will have fullImage
    return ApiMethods.postFile(compressedBytes, compressedFullImage,
        Const.HOST_URL_STAGING + "App/GeminiBot",
        retry: 0);
  }

  List<Medicine> _medicineList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cropped image')),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(widget.bytes),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Call function to send image
          try {
            var rs = await _sendImageToApi();
            if (rs == null) {
              _showErrorNotification();
            } else {
              List<Medicine> medicineList = (rs?["verified"] as List)
                  .map((item) => Medicine.fromJson(item))
                  .toList();
              setState(() {
                _medicineList = medicineList;
              });
              _showMedicineListModal(context);
            }
          } finally {
            BotToast.closeAllLoading();
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }

  void _showErrorNotification() {
    // Implement your notification logic here
    // For example:
    // Show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không phân tích được đơn thuốc, hãy gửi ảnh khác '),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showMedicineListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.9, // Set maximum height as 90% of screen height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: Text(
                    'Medicine Scanner',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0096C7), // Adjusted color value
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _medicineList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildMedicineCard(_medicineList[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Unit: ${medicine.unit}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              'Quantity: ${medicine.quantity}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              'Usage: ${medicine.usage}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Medicine {
  String name;
  String unit;
  String quantity;
  String usage;

  Medicine({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.usage,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] != "" ? json['name'] : 'Chưa xác định',
      unit: json['unit'] != "" ? json['unit'] : 'Chưa xác định',
      quantity: json['quantity'] != "" ? json['quantity'] : 'Chưa xác định',
      usage: json['usage'] != "" ? json['usage'] : 'Chưa xác định',
    );
  }
}

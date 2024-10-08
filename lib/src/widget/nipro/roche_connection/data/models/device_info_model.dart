import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class DeviceInfoModel {
  String image;
  String? imagePin;
  String name;
  List<TutorialModel> tutorials = [];

  DeviceInfoModel({
    required this.image,
    required this.imagePin,
    required this.name,
    required this.tutorials,
  });
}

class TutorialModel {
  int index;
  String image;
  Widget title;
  Widget? description;

  TutorialModel({
    required this.index,
    required this.image,
    required this.title,
    this.description,
  });
}

List<DeviceInfoModel> examples = [
  // * Accu Chek Instant
  DeviceInfoModel(
    image: 'lib/res/drawables/accu-chek-instant.png',
    imagePin: 'lib/res/drawables/accu-chek-instant-6.png',
    name: 'Accu Chek Instant',
    tutorials: [
      TutorialModel(
        index: 0,
        image: 'lib/res/drawables/accu-chek-instant-1.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              height: 1.5,
              fontSize: 18,
              color: R.color.textDark,
            ),
            children: [
              TextSpan(
                text: 'Từ ',
              ),
              TextSpan(
                text: 'máy chưa bật, bấm và giữ ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'nút phía dưới ',
              ),
              TextSpan(
                text: 'trong 5 giây.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        description: Text(
          'Lưu ý: Tắt máy nếu đang bật',
          style: TextStyle(
            color: Color(0xFF777E90),
          ),
        ),
      ),
      TutorialModel(
        index: 1,
        image: 'lib/res/drawables/accu-chek-instant-2.png',
        title: Text(
          'Máy đo sẽ có biểu tượng ghép nối xuất hiện và nhấp nháy.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: R.color.textDark),
        ),
      ),
      TutorialModel(
        index: 2,
        image: 'lib/res/drawables/accu-chek-instant-3.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Bấm ',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: '“Kết nối thiết bị” ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'và nhập mã ',
              ),
              TextSpan(
                text: 'PIN ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'để kết nối với ứng dụng DiaB.',
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 3,
        image: 'lib/res/drawables/accu-chek-instant-4.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Phía sau máy đo có mã ',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: 'PIN 6 số ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ', nhập mã vào ứng dụng để kết nối.',
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 4,
        image: 'lib/res/drawables/accu-chek-instant-5.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Chữ ',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: 'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'sẽ xuất hiện nếu ghép nối thành công. Chữ',
              ),
              TextSpan(
                text: 'Err',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'sẽ xuất hiện nếu ghép nối không thành công.',
              ),
            ],
          ),
        ),
      ),
    ],
  ),
  // * Accu Chek Guide
  DeviceInfoModel(
    image: 'lib/res/drawables/accu-chek-guide.png',
    imagePin: 'lib/res/drawables/accu-chek-guide-7.png',
    name: 'Accu Chek Guide',
    tutorials: [
      TutorialModel(
        index: 0,
        image: 'lib/res/drawables/accu-chek-guide-1.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: R.color.textDark,
            ),
            children: [
              TextSpan(
                text: 'Bật máy bằng cách ấn vào ',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: '(OK).\n',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'Từ Menu chính, ',
              ),
              TextSpan(
                text: 'ấn (Xuống) ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'để chọn ',
              ),
              TextSpan(
                text: 'Settings ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: '(Cài đặt). ',
              ),
              TextSpan(
                text: 'Ấn (OK).',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 1,
        image: 'lib/res/drawables/accu-chek-guide-2.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Ấn (Xuống) ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'để chọn ',
              ),
              TextSpan(
                text: 'Wireless\n',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: '(Không dây). ',
              ),
              TextSpan(
                text: 'Ấn (OK).',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 2,
        image: 'lib/res/drawables/accu-chek-guide-3.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Chọn ',
              ),
              TextSpan(
                text: '(Pair Device). Ấn (OK).',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 3,
        image: 'lib/res/drawables/accu-chek-guide-4.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                  text:
                      'Máy đo sẽ hiển thị mã. Nhập mã\nhiển thị vào app kết nối DiaB.'),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 4,
        image: 'lib/res/drawables/accu-chek-guide-5.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                text: 'Bấm ',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: '“Kết nối thiết bị”  ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'và nhập mã ',
              ),
              TextSpan(
                text: 'PIN ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'để kết nối với ứng dụng DiaB.',
              ),
            ],
          ),
        ),
      ),
      TutorialModel(
        index: 5,
        image: 'lib/res/drawables/accu-chek-guide-6.png',
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 18, color: R.color.textDark),
            children: [
              TextSpan(
                  text:
                      'Đã hoàn thành ghép nối. App sẽ\nnhận được chỉ số từ thiết bị.'),
            ],
          ),
        ),
      ),
    ],
  ),
  // * NIPRO Premier a
  DeviceInfoModel(
      image: 'lib/res/drawables/nipro_device.png',
      imagePin: '',
      name: 'NIPRO Premier a',
      tutorials: []),
];
DeviceInfoModel guideReconnection = DeviceInfoModel(
  image: 'lib/res/drawables/accu-chek-guide.png',
  imagePin: '',
  name: 'Accu Chek Guide',
  tutorials: [
    TutorialModel(
      index: 0,
      image: 'lib/res/drawables/accu-chek-guide-8.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: R.color.textDark,
          ),
          children: [
            TextSpan(
              text: 'Bật máy bằng cách ấn vào ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: '(OK).\n',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'Từ Menu chính, ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: 'ấn (Xuống) ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'để chọn ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: 'My data ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '(Cài đặt). ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: 'Ấn (OK).',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
    TutorialModel(
      index: 1,
      image: 'lib/res/drawables/accu-chek-guide-9.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 18, color: R.color.textDark),
          children: [
            TextSpan(
              text: 'Ấn (Xuống)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: ' để chọn ',
            ),
            TextSpan(
              text: 'Data Transfer. Ấn (OK).',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
    TutorialModel(
      index: 2,
      image: 'lib/res/drawables/accu-chek-guide-10.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 18, color: R.color.textDark),
          children: [
            TextSpan(
              text: 'Ấn (Xuống) ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'để chọn ',
            ),
            TextSpan(
              text: 'Wireless.\nẤn (OK).',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
    TutorialModel(
      index: 3,
      image: 'lib/res/drawables/accu-chek-guide-11.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 18,
            color: R.color.textDark,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
                text:
                    'Màn hình hiển thị kết nối, Bạn mở app và bấm “Kết nối thiết bị”'),
          ],
        ),
      ),
    ),
    TutorialModel(
      index: 4,
      image: 'lib/res/drawables/accu-chek-guide-12.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 18, color: R.color.textDark),
          children: [
            TextSpan(
              text: 'Bấm ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: '“Kết nối thiết bị”  ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
    TutorialModel(
      index: 5,
      image: 'lib/res/drawables/accu-chek-guide-6.png',
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 18, color: R.color.textDark),
          children: [
            TextSpan(
                text:
                    'Đã hoàn thành ghép nối. App sẽ\nnhận được chỉ số từ thiết bị.'),
          ],
        ),
      ),
    ),
  ],
);

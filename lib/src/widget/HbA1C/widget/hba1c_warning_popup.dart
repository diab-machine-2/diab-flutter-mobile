import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class HbA1cWarningPopup extends StatefulWidget {
  final VoidCallback onReInput;
  final VoidCallback onConfirm;

  const HbA1cWarningPopup({
    Key? key,
    required this.onReInput,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<HbA1cWarningPopup> createState() => _HbA1cWarningPopupState();
}

class _HbA1cWarningPopupState extends State<HbA1cWarningPopup> {
  void _reInput() {
    widget.onReInput();
  }

  void _confirm() {
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close button at top right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _reInput,
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
              const SizedBox(height: 8),

              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE53E3E).withOpacity(0.1),
                ),
                child: Image.asset(
                  R.drawable.ic_bloodpressure_warning,
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'HbA1c trong ngưỡng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.color0xff636A6B,
                  fontFamily: R.font.sfpro,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Không an toàn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: R.color.textDark,
                  fontFamily: R.font.sfpro,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Nếu có các triệu chứng thở nhanh, đau bụng, nôn ói,.. gặp bác sĩ sớm để được tư vấn và điều chỉnh toa thuốc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: R.color.textDark,
                  fontFamily: R.font.sfpro,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(color: R.color.greenGradientBottom),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      onPressed: _reInput,
                      child: Text(
                        'Nhập lại',
                        style: TextStyle(
                          color: R.color.greenGradientBottom,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: R.font.sfpro,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: R.color.greenGradientBottom,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      onPressed: _confirm,
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: R.color.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: R.font.sfpro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

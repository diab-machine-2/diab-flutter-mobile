import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

typedef OnItemCallback = void Function(HomeMeasurementIndex index);

class AddMeasurement extends StatelessWidget {
  const AddMeasurement({
    super.key,
    required this.measurements,
    required this.onItemTap,
  });

  final List<HomeMeasurementIndex> measurements;
  final OnItemCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Container(
      height: 600.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 48.0),
                Text(
                  "Thêm chỉ số",
                  style: R.style.appBarTitle,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          ListView.separated(
            padding: EdgeInsets.fromLTRB(28.0, 8.0, 28.0, 16.0),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final measurement = measurements[index];
              return InkWell(
                onTap: () => onItemTap(measurement),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE1FAF8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        measurement.icon,
                        width: 32.0,
                        height: 32.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          measurement.title,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF008479),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Icon(
                        Icons.chevron_right,
                        size: 24.0,
                        color: Color(0xFF008479),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemCount: measurements.length,
          ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'shared_profile.dart';

class SharedProfilePage extends StatefulWidget {
  const SharedProfilePage();

  @override
  _SharedProfilePageState createState() => _SharedProfilePageState();
}

class _SharedProfilePageState extends State<SharedProfilePage> {
  late final SharedProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SharedProfileCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          background: R.drawable.bg_lesson_detail,
          title: R.string.shared_profile_list.tr(),
          showCloseBackButton: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(R.drawable.ic_account, width: 56, height: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lê Hương Trúc',
                            style: TextStyle(
                              color: R.color.grey_1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bệnh viện Hồng Ngọc',
                            style: TextStyle(
                              color: Color(0xff888C9F),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Ngày chia sẻ: 25/12/2021',
                            style: TextStyle(
                              color: Color(0xff888C9F),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // TODO(Tuyen): Stop sharing
                      },
                      child: Image.asset(
                        R.drawable.ic_stop_sharing,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

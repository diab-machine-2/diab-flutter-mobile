import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/medicine/medicine_add_page.dart';

import '../../../res/R.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../modal/medicine/medicine_tablet_model.dart';
import '../../model/response/filter_data_response.dart';
import '../../utils/navigator_name.dart';
import '../helper/tracking_manager.dart';

class MedicineSearchPage extends StatefulWidget {
  const MedicineSearchPage({super.key, this.medicineMode});
  final MedicineMode? medicineMode;

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late MedicineMode _medicineMode;

  @override
  void initState() {
    if (widget.medicineMode == null) {
      _medicineMode = MedicineMode.create;
    } else {
      _medicineMode = widget.medicineMode!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineBloc(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        appBar: AppBar(
          leading: IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.white),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          title: Transform(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                R.string.add_medicine.tr(),
                style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          actions: [
            Center(
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    R.string.tutorial.tr(),
                    style: TextStyle(color: R.color.white, fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: R.color.transparent,
          //No more green
          elevation: 0.0,
          //Shadow gone
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [R.color.greenGradientMid, R.color.greenGradientBottom]),
            ),
          ),
        ),
        body: _buildContainer(),
      ),
    );
  }

  Widget _buildContainer() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchText(context),
              if (state is MedicineLoading)
                Center(child: CircularProgressIndicator())
              else if (state is MedicineSearchSuccess)
                _buildSearchResult(state.searchResult?.data ?? [], context)
              else if (state is MedicineError)
                  Center(child: Text('Error: ${state.message}'))
                else
                  SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchText(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.5,
          color: R.color.color0xffE5E5E5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: R.string.enter_key_word.tr(),
                counterText: '',
              ),
              style: TextStyle(
                color: R.color.grey_2,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              onChanged: (text) {
                context.read<MedicineBloc>().add(SearchMedicineEvent(text));
              },
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              context.read<MedicineBloc>().add(SearchMedicineEvent(_searchController.text));
            },
            child: Image.asset(
              R.drawable.ic_search,
              color: R.color.gray,
              width: 24,
              height: 24,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResult(List<MedicineTabletModel> data, BuildContext context) {
    if (data.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Không tìm thấy thuốc của bạn', style: TextStyle(fontSize: 15, color: R.color.color0xff5E6566),),
              InkWell(
                onTap: () {
                  context.read<MedicineBloc>().add(SearchMedicineEvent(_searchController.text));
                },
                child: Text(
                  'Thêm ${_searchController.text}',
                  style: TextStyle(fontSize: 15, color: R.color.color0xffB4802D, decoration: TextDecoration.underline,),
                ),
              ),
            ],
          )
        ],
      );
    }

    return Expanded(
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 8, top: 10),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          final item = data[index];
          return _buildItem(context, item);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, MedicineTabletModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff111515,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: R.color.color0xffDCFFFC,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1.5,
                color: R.color.color0xffDCFFFC,
              ),
            ),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.pushNamed(context, NavigatorName.medicine_add, arguments: {
                  'medicineItem': item,
                  'mode': _medicineMode,
                });
                if (result != null && result is MedicineItemModel && _medicineMode != MedicineMode.create) {
                  Navigator.pop(context, result);
                }
              },
              child: Row(
                children: [
                  Text(
                    R.string.choose.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff008479,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(R.drawable.ic_add, width: 16,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

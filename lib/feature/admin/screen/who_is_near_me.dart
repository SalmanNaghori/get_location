import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/constant/app_image.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/feature/admin/cubit/user_in_range_cubit.dart';
import 'package:get_location/feature/admin/screen/widget/user_list_widget.dart';

class WhoIsNearMe extends StatefulWidget {
  const WhoIsNearMe({super.key});

  @override
  State<WhoIsNearMe> createState() => _WhoIsNearMeState();
}

class _WhoIsNearMeState extends State<WhoIsNearMe> {
  UserInRangeCubit userInRangeCubit = UserInRangeCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userInRangeCubit.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: userInRangeCubit,
      child: Scaffold(
        backgroundColor: ConstColor.whiteColor,
        appBar: CustomAppBar.blankAppBar(title: AppString.whoIsNearMe),
        body: BlocBuilder<UserInRangeCubit, UserInRangeState>(
          builder: (context, state) {
            if (state.users.isNotEmpty) {
              return UserListWidget(
                userList: state.users,
              );
            } else {
              return Center(
                child: Image.asset(ImageAsset.icDataEmpty),
              );
            }
          },
        ),
      ),
    );
  }
}

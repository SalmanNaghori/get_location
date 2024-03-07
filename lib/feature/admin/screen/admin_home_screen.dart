import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_image.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/firebase/notification_service.dart';
import 'package:get_location/core/util/logger.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/feature/admin/cubit/user_in_range_cubit.dart';
import 'package:get_location/feature/admin/login/admin_login_screen.dart';
import 'package:get_location/feature/admin/screen/view_user_screen.dart';
import 'package:get_location/feature/admin/screen/who_is_near_me.dart';
import 'package:get_location/feature/admin/screen/widget/custom_card_widget.dart';
import 'package:get_location/feature/user_screen/cubit/get_user_location_cubit.dart';

class AdminHomeSCreen extends StatefulWidget {
  const AdminHomeSCreen({super.key});

  @override
  State<AdminHomeSCreen> createState() => _AdminHomeSCreenState();
}

class _AdminHomeSCreenState extends State<AdminHomeSCreen> {
  LocationCubit locationCubit = LocationCubit(UserType.admin);
  UserInRangeCubit userInRangeCubit = UserInRangeCubit();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationCubit.getCurrentLocation();
    locationCubit.startLocationService();
    userInRangeCubit.fetchData();
    NotificationsService().requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: locationCubit,
        ),
        BlocProvider.value(value: userInRangeCubit)
      ],
      child: Scaffold(
        backgroundColor: ConstColor.whiteColor,
        appBar: CustomAppBar.blankAppBar(title: "Welcome Admin"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomCardWidget(
                  height: 200,
                  width: 300,
                  onTap: () {
                    navigation(const ViewUserScreen());
                  },
                  imgae: ImageAsset.icViewUser,
                  color: ConstColor.primaryColor,
                  name: AppString.viewUsers,
                ),
                CustomCardWidget(
                  height: 200,
                  width: 300,
                  onTap: () {
                    navigation(const WhoIsNearMe());
                  },
                  imgae: ImageAsset.icNearMeView,
                  color: ConstColor.primaryColor,
                  name: AppString.whoIsNearMe,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            EasyLoading.show();
            _logout();
          },
          backgroundColor: ConstColor.primaryColor,
          child: const Icon(CupertinoIcons.power),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        (Route<dynamic> route) => false,
      );
      // await SharedPrefUtils.setIsUserLoggedIn(false);
      locationCubit.stopLocationService();
      await _auth.signOut();
    } catch (e) {
      EasyLoading.dismiss();
      logger.e('Error during logout: $e');
    }
  }

  Future<void> navigation(Widget widgetName) async {
    // EasyLoading.dismiss();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widgetName,
      ),
    );
  }
}

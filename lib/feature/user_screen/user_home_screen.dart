import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/core/widget/my_button.dart';
import 'package:get_location/feature/auth/login_screen.dart';
import 'package:get_location/feature/auth/model/user_model.dart';
import 'package:get_location/feature/user_screen/cubit/get_user_cubit.dart';
import 'package:get_location/feature/user_screen/cubit/get_user_location_cubit.dart';
import 'package:get_location/feature/user_screen/widget/welcome_animation.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  FirebaseCubit firebaseCubit = FirebaseCubit();
  LocationCubit location = LocationCubit();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is loaded
    firebaseCubit.fetchData();
    location.startLocationService();
    location.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: firebaseCubit,
        ),
        BlocProvider.value(
          value: location,
        ),
      ],
      child: Scaffold(
        backgroundColor: ConstColor.whiteColor,
        appBar: CustomAppBar.blankAppBar(title: AppString.appName),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LottieAnimationAudio(),
                BlocBuilder<FirebaseCubit, List<UserModel>>(
                  builder: (context, userList) {
                    // Handle different states (loading, error, data)
                    if (userList.isEmpty) {
                      return const Center(
                        child: Text("List is empty"),
                      );
                    } else {
                      // Display your user data
                      return ListTile(
                        title: Text(
                          'User: ${userList[0].firstName} ${userList[0].secondName}',
                          style: const TextStyle(
                              fontSize: 30,
                              fontFamily: "chewy",
                              color: ConstColor.primaryColor),
                        ),
                        subtitle: Text(
                          'Email: ${userList[0].email}',
                          style: const TextStyle(
                              fontSize: 30,
                              fontFamily: "chewy",
                              color: ConstColor.primaryColor),
                        ),
                        // Add more fields as needed
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        locationData('Latitude: ' + state.latitude),
                        locationData('Longitude: ' + state.longitude),
                        locationData('Time: ' + state.time),
                        locationData('IsServiceRunning: ' +
                            state.isServiceRunning.toString()),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  title: AppString.logOut,
                  onPressed: () async {
                    EasyLoading.show();
                    _logout();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      // await SharedPrefUtils.setIsUserLoggedIn(false);

      await _auth.signOut();
    } catch (e) {
      EasyLoading.dismiss();
      log('Error during logout: $e');
    }
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
}

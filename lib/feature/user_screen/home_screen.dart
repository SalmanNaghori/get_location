import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/core/widget/my_button.dart';
import 'package:get_location/feature/auth/login_screen.dart';
import 'package:get_location/feature/auth/model/user_model.dart';
import 'package:get_location/feature/user_screen/cubit/get_user_cubit.dart';
import 'package:get_location/feature/user_screen/widget/welcome_animation.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  FirebaseCubit firebaseCubit = FirebaseCubit();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is loaded
    firebaseCubit.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: firebaseCubit,
      child: Scaffold(
        backgroundColor: ConstColor.whiteColor,
        appBar: CustomAppBar.blankAppBar(title: AppString.appName),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const LottieAnimationAudio(),
              BlocBuilder<FirebaseCubit, List<UserModel>>(
                builder: (context, userList) {
                  // Handle different states (loading, error, data)
                  if (userList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
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
                height: 20,
              ),
              MyButton(
                  title: AppString.logOut,
                  onPressed: () async {
                    _logout();
                  })
            ],
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
}

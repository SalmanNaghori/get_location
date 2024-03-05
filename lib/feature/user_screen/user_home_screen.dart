import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:get_location/core/util/logger.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/core/widget/my_button.dart';
import 'package:get_location/feature/admin/cubit/location_dif_cubit.dart';
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
  LocationCubit locationCubit = LocationCubit(UserType.user);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocationDiffCubit locationDiffCubit = LocationDiffCubit(
    userId: SharedPrefUtils.getUserId(),
    adminId: SharedPrefUtils.getAdminId(),
  );

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is loaded
    firebaseCubit.fetchData();

    locationCubit.getCurrentLocation();

    locationDiffCubit.startLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: firebaseCubit,
        ),
        BlocProvider.value(
          value: locationCubit,
        ),
        BlocProvider.value(value: locationDiffCubit)
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
                  height: 40,
                  miniWidth: 100,
                  title: AppString.logOut,
                  onPressed: () async {
                    EasyLoading.show();
                    _logout();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                BlocBuilder<LocationDiffCubit, DistanceState>(
                  builder: (context, state) {
                    // Use the state to display UI elements or trigger actions
                    if (state.distance <= 0.01) {
                      addSubCollection();
                      return Text('Distance: <<<<<<<${state.distance}>>>>');
                    } else {
                      deleteSubCollection();
                      return Text('Distance: ${state.distance}');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      locationCubit.stopLocationService();

      // Stop Firestore listener
      locationDiffCubit.close();

      Future.delayed(Duration(seconds: 2), () async {
        await _auth.signOut();
        EasyLoading.dismiss();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      EasyLoading.dismiss();
      log('Error during logout: $e');
    }
  }

  Future<void> addSubCollection() async {
    try {
      var subCollection = FirebaseFirestore.instance
          .collection("admin")
          .doc(SharedPrefUtils.getAdminId())
          .collection("usersInRange")
          .doc(SharedPrefUtils.getUserId());

      await subCollection.set({
        'email': SharedPrefUtils.getUserModel().email,
        'firstName': SharedPrefUtils.getUserModel().firstName,
        'secondName': SharedPrefUtils.getUserModel().secondName,
      });

      logger.w('Subcollection added successfully');
    } catch (error) {
      logger.e('Error adding subcollection $error');
      // You can handle the error here, e.g., show a toast or log it to a crash reporting service
    }
  }

  Future<void> deleteSubCollection() async {
    try {
      var subCollection = FirebaseFirestore.instance
          .collection("admin")
          .doc(SharedPrefUtils.getAdminId())
          .collection("usersInRange")
          .doc(SharedPrefUtils.getUserId());

      await subCollection.delete();

      logger.f('Subcollection deleted successfully');
    } catch (error) {
      logger.e('Error deleting subcollection $error');
      // You can handle the error here, e.g., show a toast or log it to a crash reporting service
    }
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    locationDiffCubit.close();
    super.dispose();
  }
}

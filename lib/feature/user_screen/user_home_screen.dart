import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/network/api_helper.dart';
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

import '../../core/util/enum.dart';
import '../../core/util/permission/location_per.dart';
import '../admin/model/admin_model.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  FirebaseCubit firebaseCubit = FirebaseCubit();
  LocationCubit locationCubit = LocationCubit(UserType.user);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AdminModel adminModel = AdminModel();
  LocationPermissionCubit locationPermissionCubit = LocationPermissionCubit();
  LocationDiffCubit locationDiffCubit = LocationDiffCubit(
    userId: SharedPrefUtils.getUserId(),
    adminId: SharedPrefUtils.getAdminId(),
  );

  final String distance = "";

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is loaded
    firebaseCubit.fetchData();

    locationPermissionCubit.getLocation();
    // locationDiffCubit.startLocationUpdates();
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
        BlocProvider.value(value: locationDiffCubit),
        BlocProvider.value(value: locationPermissionCubit),
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
                BlocListener<LocationDiffCubit, DistanceState>(
                  listener: (context, state) {
                    // Use the new state to trigger actions
                    state.distance.toString();

                    // Perform actions based on the distanceString value
                    if (state.distance == 0.0) {
                      logger.e("state.distance=======${state.distance}");
                    } else if (state.distance <= 0.01) {
                      addSubCollection();
                    } else {
                      deleteSubCollection();
                    }

                    // Use distanceString as needed
                    // For example, you can store it in a variable, pass it to a function, etc.
                  },
                  child: BlocBuilder<LocationDiffCubit, DistanceState>(
                    builder: (context, state) {
                      // Use the state to display UI elements
                      return Text('Distance: ${state.distance.toString()}');
                    },
                  ),
                ),
                BlocBuilder<LocationPermissionCubit, LocationPermissionState>(
                  builder: (context, state) {
                    if (state is LocationPermissionGranted) {
                      // Handle permission granted
                      locationCubit.startLocationService();
                      locationCubit.getCurrentLocation();
                      return const Center(
                          child: Text('Location Permission Granted'));
                    } else if (state is LocationPermissionDenied) {
                      // Handle permission denied
                      return const Center(
                          child: Text('Location Permission Denied'));
                    } else if (state is LocationError) {
                      // Handle location error
                      return const Center(child: Text('Location Error'));
                    } else if (state is LocationServiceEnabled) {
                      // Handle location error
                      return const Center(child: Text('Location is enabled'));
                    } else if (state is LocationServiceDisabled) {
                      // Handle location error
                      return const Center(child: Text('Location is disabled'));
                    } else {
                      // Handle other states as needed
                      return const Center(child: Text('Unknown State'));
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
      SharedPrefUtils.setFirstPermissionLocation(false);
      Future.delayed(const Duration(seconds: 2), () async {
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

      var adminCollection =
          await FirebaseFirestore.instance.collection("admin").get();

      for (var adminDoc in adminCollection.docs) {
        try {
          logger.d("Admin data Home screen: ${adminDoc.data()}");
          adminModel = AdminModel.fromMap(adminDoc.data());
          SharedPrefUtils.setFcmAdminToken(adminModel.fcmToken ?? "");
          logger.f("FCMToken===========${SharedPrefUtils.getFcmAdminToken()}");
          if (SharedPrefUtils.getFcmAdminToken().isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              ApiHelper().sendNotification("User In range");
            });
          }
        } catch (e) {
          log("Error storing AdminId in SharedPreferences: $e");
        }

        // Break out of the loop after the first iteration
        break;
      }

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

      var adminCollection =
          await FirebaseFirestore.instance.collection("admin").get();

      for (var adminDoc in adminCollection.docs) {
        try {
          logger.d("Admin data Home screen: ${adminDoc.data()}");
          adminModel = AdminModel.fromMap(adminDoc.data());
          SharedPrefUtils.setFcmAdminToken(adminModel.fcmToken ?? "");
          logger.f("FCMToken===========${SharedPrefUtils.getFcmAdminToken()}");
          if (SharedPrefUtils.getFcmAdminToken().isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              ApiHelper().sendNotification("User out of range");
            });
          }
        } catch (e) {
          log("Error storing AdminId in SharedPreferences: $e");
        }

        // Break out of the loop after the first iteration
        break;
      }

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

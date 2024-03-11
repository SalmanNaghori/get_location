import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:get_location/core/util/logger.dart';

import '../../../core/util/enum.dart';

class LocationState {
  final String latitude;
  final String longitude;
  final String time;
  final bool isServiceRunning;

  LocationState({
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.isServiceRunning,
  });

  LocationState copyWith({
    String? latitude,
    String? longitude,
    String? time,
    bool? isServiceRunning,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      time: time ?? this.time,
      isServiceRunning: isServiceRunning ?? this.isServiceRunning,
    );
  }
}

class LocationCubit extends Cubit<LocationState> {
  final UserType userType;

  LocationCubit(this.userType)
      : super(LocationState(
          latitude: 'waiting...',
          longitude: 'waiting...',
          time: 'waiting...',
          isServiceRunning: false,
        ));

  void startLocationService() async {
    logger.d('Location service starting...');

    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );

    await BackgroundLocation.startLocationService(distanceFilter: 10);

    logger.d('Location service started');

    emit(state.copyWith(isServiceRunning: true));
  }

  void stopLocationService() {
    BackgroundLocation.stopLocationService();
    logger.f('Location service stopped');
    emit(state.copyWith(isServiceRunning: false));
  }

  void _updateLocationInFirestore(
    String userId,
    double latitude,
    double longitude,
    int time,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "adminLatitude": latitude.toString(),
        "adminLongitude": longitude.toString(),
        "time": DateTime.fromMillisecondsSinceEpoch(time).toString(),
      });
      await FirebaseFirestore.instance
          .collection("admin")
          .doc(SharedPrefUtils.getAdminId())
          .update({
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "time": DateTime.fromMillisecondsSinceEpoch(time).toString(),
      });
      logger.i('Location updated for user: $userId');
    } catch (e, stacktrace) {
      logger.e('Error updating location: $e, Stacktrace: $stacktrace');
    }
  }

  void _handleLocationUpdate(Location location) {
    emit(LocationState(
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
      time: DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
          .toString(),
      isServiceRunning: state.isServiceRunning,
    ));
  }

  void getCurrentLocation() async {
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        final userId = user.email;

        BackgroundLocation.getLocationUpdates((location) async {
          _handleLocationUpdate(location);

          if (userType == UserType.admin) {
            // Update admin's location in Firestore
            _updateLocationInFirestore(
              userId!,
              location.latitude!,
              location.longitude!,
              location.time!.toInt(),
            );

            // Iterate through all user documents and update their locations
            final allUsers =
                await FirebaseFirestore.instance.collection("users").get();
            for (var userDocData in allUsers.docs) {
              if (userDocData.id != userId) {
                _handleLocationUpdate(location);
                _updateLocationInFirestore(
                  userDocData.id,
                  location.latitude!,
                  location.longitude!,
                  location.time!.toInt(),
                );
              }
            }
          } else {
            // Update user's location in Firestore
            _updateLocationInFirestore(
              userId!,
              location.latitude!,
              location.longitude!,
              location.time!.toInt(),
            );
          }
        });
      }
    } catch (e, stacktrace) {
      logger.e('Error getting current location: $e, Stacktrace: $stacktrace');
      // Handle the error as needed (e.g., show a message to the user)
    }
  }
}

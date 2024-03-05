import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/util/logger.dart';

enum UserType { user, admin }

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

    await BackgroundLocation.startLocationService(distanceFilter: 20);

    logger.d('Location service started');

    emit(state.copyWith(isServiceRunning: true));
  }

  void stopLocationService() {
    BackgroundLocation.stopLocationService();
    logger.f('Location service stopped');
    emit(state.copyWith(isServiceRunning: false));
  }

  void getCurrentLocation() async {
    try {
      final _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;

      // Firebase
      final userDoc = FirebaseFirestore.instance
          .collection(userType == UserType.user ? "users" : "admin")
          .doc(user?.email);

      // Check if the user/admin has existing data
      final existingData = await userDoc.get();
      if (existingData.exists) {
        logger.i('User/Admin have data');
        startLocationService();

        BackgroundLocation.getLocationUpdates((location) {
          emit(LocationState(
            latitude: location.latitude.toString(),
            longitude: location.longitude.toString(),
            time: DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
                .toString(),
            isServiceRunning: state.isServiceRunning,
          ));
          // Update the location in Firestore
          userDoc.update({
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "time": DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
                .toString(),
          });
        });
      } else {
        logger.e("user/admin Data not Exists $existingData");
      }
    } catch (e, stacktrace) {
      logger.e('Error getting current location: $e, Stacktrace: $stacktrace');
      // Handle the error as needed (e.g., show a message to the user)
    }
  }
}

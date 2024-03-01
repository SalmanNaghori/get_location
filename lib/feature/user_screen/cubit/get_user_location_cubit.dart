import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  LocationCubit()
      : super(LocationState(
          latitude: 'waiting...',
          longitude: 'waiting...',
          time: 'waiting...',
          isServiceRunning: false,
        ));

  void startLocationService() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );

    await BackgroundLocation.startLocationService(distanceFilter: 20);

    emit(state.copyWith(isServiceRunning: true));
  }

  void stopLocationService() {
    BackgroundLocation.stopLocationService();
    emit(state.copyWith(isServiceRunning: false));
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      emit(LocationState(
        latitude: location.latitude.toString(),
        longitude: location.longitude.toString(),
        time: DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
            .toString(),
        isServiceRunning: state.isServiceRunning,
      ));
      // firebase
      final _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(user?.email);
      userDoc.update({
        "latitude": location.latitude.toString(),
        "longitude": location.longitude.toString(),
        "time": DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
            .toString()
      });
    });
  }
}

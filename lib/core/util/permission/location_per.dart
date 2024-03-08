import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:location/location.dart';

// States
abstract class LocationPermissionState {}

class LocationInitialState extends LocationPermissionState {}

class LocationPermissionGranted extends LocationPermissionState {}

class LocationPermissionDenied extends LocationPermissionState {}

class LocationError extends LocationPermissionState {}

class LocationServiceEnabled extends LocationPermissionState {}

class LocationServiceDisabled extends LocationPermissionState {}

// Events
abstract class LocationEvent {}

class GetLocationEvent extends LocationEvent {}

class LocationPermissionCubit extends Cubit<LocationPermissionState> {
  final Location location = Location();

  LocationPermissionCubit() : super(LocationInitialState()) {
    // Listen to location changes and update the state accordingly
    location.onLocationChanged.listen((LocationData? locationData) {
      if (locationData != null) {
        emit(LocationServiceEnabled());
      } else {
        emit(LocationServiceDisabled());
      }
    });

    // Check and emit initial service status
    checkAndEmitServiceStatus();
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          SharedPrefUtils.setFirstPermissionLocation(false);
          emit(LocationError());
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          SharedPrefUtils.setFirstPermissionLocation(false);
          emit(LocationPermissionDenied());
          return;
        }
      }

      // You can do something with the locationData here
      // For example, you might want to store it in a variable or call another function.
      // Example: handleLocation(locationData);

      // Return true indicating permission was granted and location data was obtained
      SharedPrefUtils.setFirstPermissionLocation(true);
      emit(LocationPermissionGranted());
    } catch (e) {
      SharedPrefUtils.setFirstPermissionLocation(false);
      emit(LocationError());
    }
  }

  void checkAndEmitServiceStatus() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled) {
      emit(LocationServiceEnabled());
    } else {
      emit(LocationServiceDisabled());
    }
  }
}

import 'dart:async';
import 'dart:developer';
import 'dart:math' show cos, sqrt, asin;

import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/util/app_util.dart';
import 'package:get_location/core/util/logger.dart';

import '../../../core/app_life_cycle/app_life_cycle.dart';

// State to represent the distance result
class DistanceState {
  final double distance;
  DistanceState(this.distance);
}

class LocationDiffCubit extends Cubit<DistanceState> {
  final AppLifecycleObserver appLifecycleObserver = AppLifecycleObserver();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId; // Replace with the actual user ID
  final String adminId; // Replace with the actual admin ID

  late StreamSubscription<DocumentSnapshot> locationSubscription;
  double previousUserLat = 0.0; // Initial value
  double previousUserLng = 0.0; // Initial value
  bool isInRange = false; // Flag to track if the user is in range
  LocationDiffCubit({required this.userId, required this.adminId})
      : super(DistanceState(0.0)) {
    // Start listening to location updates when the cubit is created
    // startLocationUpdates();
    isCubitActive = true;
    // startLocationListener();
  }

  bool isCubitActive = false;
  // Function to calculate distance
  double calculateDistance(
      double userLat, double userLng, double adminLat, double adminLng) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((adminLat - userLat) * p) / 2 +
        c(userLat * p) *
            c(adminLat * p) *
            (1 - c((adminLng - userLng) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  // Function to trigger distance calculation
  Future<void> calculateDistanceAndUpdateState() async {
    try {
      if (!isCubitActive) {
        return;
      }

      // Retrieve user location
      final userSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        double userLat =
            //  22.990075;
            double.parse(userSnapshot['latitude']);
        double userLng =
            //  72.515045;
            double.parse(userSnapshot['longitude']);
//22.990075, 72.515045
        logger.d('User Data: Latitude = $userLat, Longitude = $userLng');

        // Retrieve admin location
        final adminSnapshot =
            await firestore.collection('admin').doc(adminId).get();

        if (adminSnapshot.exists) {
          double adminLat = double.parse(adminSnapshot['latitude']);
          double adminLng = double.parse(adminSnapshot['longitude']);

          logger.d('Admin Data: Latitude = $adminLat, Longitude = $adminLng');

          // Calculate distance
          double distance =
              calculateDistance(userLat, userLng, adminLat, adminLng);

          logger.w('Calculated Distance: $distance meters');

          // Emit the new state with the calculated distance
          logger.w('Calculating distance and updating state');
          emit(DistanceState(distance));
        }
      }
    } catch (e, stacktrace) {
      logger.e(
          'Error calculating calculateDistanceAndUpdateState: $e, $stacktrace');
    }
  }

  // Function to start listening to location updates
  void startLocationUpdates() {
    try {
      logger.d('Stream triggered. User ID: $userId');
      locationSubscription = firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot userSnapshot) async {
        if (userSnapshot.exists) {
          // Extract latitude and longitude from the user document
          double newUserLat = double.parse(userSnapshot['latitude']);
          double newUserLng = double.parse(userSnapshot['longitude']);

          // Check if the values have changed
          if (newUserLat != previousUserLat || newUserLng != previousUserLng) {
            // Update the previous values
            previousUserLat = newUserLat;
            previousUserLng = newUserLng;

            // Retrieve admin's location from Firestore
            DocumentSnapshot adminSnapshot =
                await firestore.collection('admin').doc(adminId).get();

            logger.e("=========$adminId");

            if (adminSnapshot.exists) {
              double adminLat = double.parse(adminSnapshot['latitude']);
              double adminLng = double.parse(adminSnapshot['longitude']);

              // Calculate distance
              double distance =
                  calculateDistance(newUserLat, newUserLng, adminLat, adminLng);

              log("============${distance.toString()}");

              if (distance <= 10.0 && !isInRange) {
                // Call calculateDistanceAndUpdateState only if within 10 meters
                calculateDistanceAndUpdateState();
                isInRange = true; // Set the flag to true
              } else if (distance > 10.0 && isInRange) {
                // User moved out of the 10-meter range, reset the flag
                isInRange = false;
              }
            } else {
              // Admin document does not exist
              logger.d('Admin document does not exist');
            }
          } else {
            AppUtils.appToast("Location values have not changed");
            // Values haven't changed
            logger.d('Location values have not changed');
          }
        } else {
          // User document does not exist
          logger.d('User document does not exist');
        }
      });
    } catch (e, stacktrace) {
      // Handle errors
      logger.e('Error during location updates: $e, $stacktrace');
    }
  }

  @override
  Future<void> close() {
    try {
      isCubitActive = false;
      locationSubscription.cancel();
      appLifecycleObserver.dispose();
      BackgroundLocation.stopLocationService();
      logger.f('Location service stopped');
      logger.f('Listener service stopped');
    } catch (e, stacktrace) {
      logger.e('Error calculating Close: $e, $stacktrace');
    }
    return super.close();
  }
}

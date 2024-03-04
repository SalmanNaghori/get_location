import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:get_location/core/util/logger.dart';

// State to represent the distance result
class DistanceState {
  final double distance;
  DistanceState(this.distance);
}

class LocationDiffCubit extends Cubit<DistanceState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId; // Replace with the actual user ID
  final String adminId; // Replace with the actual admin ID

  late StreamSubscription<DocumentSnapshot> locationSubscription;

  LocationDiffCubit({required this.userId, required this.adminId})
      : super(DistanceState(0.0)) {
    // Start listening to location updates when the cubit is created
    startLocationUpdates();
  }

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
      // Retrieve user location
      final userSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        double userLat = double.parse(userSnapshot['latitude']);
        double userLng = double.parse(userSnapshot['longitude']);

        logger.d('User Data: Latitude = $userLat, Longitude = $userLng');
        logger.e(">>>>>>>>>>>>>>>>>${SharedPrefUtils.getAdminId()}");
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
          emit(DistanceState(distance));
        }
      }
    } catch (e, stacktrace) {
      logger.e('Error calculating distance: $e, $stacktrace');
    }
  }

  // Function to start listening to location updates
  void startLocationUpdates() {
    try {
      locationSubscription = firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot userSnapshot) {
        if (userSnapshot.exists) {
          calculateDistanceAndUpdateState();
        }
      });
    } catch (e, stacktrace) {
      logger.e('Error calculating distance: $e, $stacktrace');
    }
  }

  @override
  Future<void> close() {
    try {
      // Cancel the stream subscription when the cubit is closed
      locationSubscription.cancel();
    } catch (e, stacktrace) {
      logger.e('Error calculating distance: $e, $stacktrace');
    }
    return super.close();
  }
}

import 'package:get_location/core/storage/shared_pref.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> getLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        SharedPrefUtils.setFirstPermissionLocation(false);

        return false;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        SharedPrefUtils.setFirstPermissionLocation(false);
        return false;
      }
    }

    LocationData locationData = await location.getLocation();
    // You can do something with the locationData here
    // For example, you might want to store it in a variable or call another function.
    // Example: handleLocation(locationData);

    // Return true indicating permission was granted and location data was obtained
    SharedPrefUtils.setFirstPermissionLocation(true);
    return true;
  }
}

// Usage example:
// In any part of your app, create an instance of LocationService and call getLocation
// from there to get the location data.

// Example:
// LocationService locationService = LocationService();
// bool isLocationPermissionGranted = await locationService.getLocation();

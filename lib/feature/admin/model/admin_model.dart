// ignore_for_file: public_member_api_docs, sort_constructors_first
class AdminModel {
  String? uid;
  String? email;
  String? fcmToken;
  String? latitude;
  String? longitude;

  AdminModel({
    this.uid,
    this.email,
    this.fcmToken,
    this.latitude,
    this.longitude,
  });

  // receiving data from server
  factory AdminModel.fromMap(Map<String, dynamic>? map) {
    return AdminModel(
      uid: map?['uid'],
      email: map?['email'],
      fcmToken: map?['fcmToken'],
      latitude: map?['latitude'],
      longitude: map?['longitude'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fcmToken': fcmToken,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'AdminModel{uid: $uid, email: $email, FcmToken: $fcmToken,latitude: $latitude, longitude: $longitude}';
  }
}

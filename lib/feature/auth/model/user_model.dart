// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  // String? image;
  // String? deviceId;
  String? fcmToken;
  String? latitude;
  String? longitude;

  UserModel({
    this.uid,
    this.email,
    this.firstName,
    this.secondName,
    // this.image,
    // this.deviceId,
    this.fcmToken,
    this.latitude,
    this.longitude,
  });

  // receiving data from server
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    return UserModel(
      uid: map?['uid'],
      email: map?['email'],
      firstName: map?['firstName'],
      secondName: map?['secondName'],
      // image: map?['image'],
      // deviceId: map?['deviceId'],
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
      'firstName': firstName,
      'secondName': secondName,
      // 'image': image,
      // 'deviceId': deviceId, // Remove the space before deviceId
      'fcmToken': fcmToken,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, firstName: $firstName, secondName: $secondName, fcmToken: $fcmToken, latitude: $latitude, longitude: $longitude}';
  }
}

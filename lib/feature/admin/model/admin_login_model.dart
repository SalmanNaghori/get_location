// ignore_for_file: public_member_api_docs, sort_constructors_first
class AdminModel {
  String? uid;
  String? email;
  String? fcmToken;

  AdminModel({this.uid, this.email, this.fcmToken});

  // receiving data from server
  factory AdminModel.fromMap(Map<String, dynamic>? map) {
    return AdminModel(
      uid: map?['uid'],
      email: map?['email'],
      fcmToken: map?['fcmToken'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fcmToken': fcmToken,
    };
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, FcmToken: $fcmToken}';
  }
}

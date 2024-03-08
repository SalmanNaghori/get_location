import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../feature/auth/model/user_model.dart';

class SharedPrefUtils {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  //Todo!: call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static Future<bool> setFcmToken(String value) async {
    var prefs = await _instance;
    return prefs.setString("FcmToken", value);
  }

  static Future<bool> setFcmAdminToken(String value) async {
    var prefs = await _instance;
    return prefs.setString("FcmAdminToken", value);
  }

  static String getFcmToken() {
    return _prefsInstance?.getString("FcmToken") ?? "";
  }

  static String getFcmAdminToken() {
    return _prefsInstance?.getString("FcmAdminToken") ?? "";
  }

  static Future<bool> setAdminId(String value) async {
    var prefs = await _instance;
    return prefs.setString("AdminId", value);
  }

  static String getAdminId() {
    return _prefsInstance?.getString("AdminId") ?? "";
  }

  static Future<bool> setUserId(String value) async {
    var prefs = await _instance;
    return prefs.setString("UserId", value);
  }

  static String getUserId() {
    return _prefsInstance?.getString("UserId") ?? "";
  }

  static Future<bool> setUserModel(UserModel value) async {
    var prefs = await _instance;

    // Convert the UserModel to a JSON string
    String userJson = jsonEncode(value.toMap());

    // Store the JSON string in SharedPreferences
    return prefs.setString("UserModel", userJson);
  }

  static UserModel getUserModel() {
    String userJson = _prefsInstance?.getString("UserModel") ?? "";

    // If the stored JSON string is not empty, decode it back to a UserModel
    return userJson.isNotEmpty
        ? UserModel.fromMap(jsonDecode(userJson))
        : UserModel();
  }

  static bool getFirstPermissionLocation() {
    return _prefsInstance?.getBool("FirstPermissionLocation") ?? false;
  }

  static Future<bool> setFirstPermissionLocation(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionLocation", value);
  }
}

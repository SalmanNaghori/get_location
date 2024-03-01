import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/app_image.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/permission/location_permission.dart';
import 'package:get_location/core/util/app_util.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/feature/auth/model/user_model.dart';
import 'package:get_location/feature/auth/signup_screen.dart';
import 'package:get_location/feature/user_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserModel loggedInUser = UserModel();
  LocationService locationService = LocationService();

  // firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    //email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ConstColor.primaryColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: AppString.email,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');

          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)");
          }
          return null;
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.vpn_key,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ConstColor.primaryColor, width: 2.0),
          ),
          //prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: AppString.password,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: ConstColor.primaryColor,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (await locationService.getLocation()) {
            signIn(emailController.text, passwordController.text);
          } else {
            AppUtils.appToast(AppString.locationPermission);
          }

          // FocusScope.of(context).requestFocus(FocusNode());
        },
        child: const Text(
          AppString.login,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: CustomAppBar.blankAppBar(
        title: "",
        whiteStatusBarText: false,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      ImageAsset.icLoginLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 45),
                  emailField,
                  const SizedBox(height: 25),
                  passwordField,
                  const SizedBox(height: 35),
                  loginButton,
                  const SizedBox(height: 15),
                  const SizedBox(
                    height: 10,
                  ),
                  // reset password

                  const SizedBox(
                    height: 25,
                  ),
                  //SignUp button
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen()));
                          },
                          child: const Text(
                            "SignUp",
                            style: TextStyle(
                                color: ConstColor.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        )
                      ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //TODO: login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show();
      try {
        FocusScope.of(context).unfocus();
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        User? user = _auth.currentUser;
        var snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.email)
            .get();
        log("Fetched Data: ${snapshot.data()}");
        loggedInUser = UserModel.fromMap(snapshot.data());

        navigation();
        log("User:$email=========LoggedIn Successfully====");
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "${error.message}";
        }
        EasyLoading.dismiss();
        AppUtils.appToast(errorMessage!);
        log("An unexpected error occurred.>${error.code.toString()}");
      } catch (e) {
        // Handle other exceptions here
        EasyLoading.dismiss();
        AppUtils.appToast("An unexpected error occurred.");
        log("Unexpected error: ${e.toString()}");
      }
    } else {
      log("Form is not valid");
      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.dismiss();
      });
    }
  }

  Future<void> navigation() async {
    EasyLoading.dismiss();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const UserHomeScreen()));
    Future.delayed(const Duration(milliseconds: 200), () {
      AppUtils.appToast("Login Successful");
    });
  }
}

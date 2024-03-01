import 'package:flutter/material.dart';
import 'package:get_location/core/constant/app_image.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/feature/admin/screen/view_user_screen.dart';

class AdminHomeSCreen extends StatefulWidget {
  const AdminHomeSCreen({super.key});

  @override
  State<AdminHomeSCreen> createState() => _AdminHomeSCreenState();
}

class _AdminHomeSCreenState extends State<AdminHomeSCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColor.whiteColor,
      appBar: CustomAppBar.blankAppBar(title: "Welcome Admin"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // height: 100,
                // width: 200,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 3,
                  ),
                ),
                child: InkWell(
                  onTap: navigation,
                  child: Image.asset(
                    ImageAsset.icViewUser,
                    height: 200,
                    width: 300,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                AppString.viewUsers,
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: "chewy",
                    color: ConstColor.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> navigation() async {
    // EasyLoading.dismiss();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViewUserScreen(),
      ),
    );
  }
}

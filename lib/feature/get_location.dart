import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_location/core/constant/app_string.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/navigator/navigator.dart';
import 'package:get_location/core/util/app_util.dart';
import 'package:get_location/feature/admin/login/admin_login_screen.dart';
import 'package:get_location/feature/admin/screen/admin_home_screen.dart';
import 'package:get_location/feature/auth/login_screen.dart';
import 'package:get_location/feature/dash_board/dash_board_cubit.dart';
import 'package:get_location/feature/user_screen/user_home_screen.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  static Logger logger = Logger();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Permission.notification.request();
    AppUtils.instance.getFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, widget) {
        return MultiProvider(
          providers: [
            BlocProvider(create: (context) => DashboardCubit()),
          ],
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: MaterialApp(
              //debugShowMaterialGrid: true,
              //showSemanticsDebugger: true,
              supportedLocales: const [
                Locale("en"),

                /// THIS IS FOR COUNTRY CODE PICKER
              ],
              localizationsDelegates: const [
                // CountryLocalizations.delegate,

                /// THIS IS FOR COUNTRY CODE PICKER
              ],
              builder: EasyLoading.init(
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
              ),

              theme: ThemeData(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: ConstColor.primaryColor,
                    ),
                useMaterial3: false,
                primaryColor: ConstColor.primaryColor,
                appBarTheme: const AppBarTheme(
                  elevation: 0.0,
                  color: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  centerTitle: true,
                ),
                // scaffoldBackgroundColor: Colors.white,
              ),

              navigatorKey: GlobalVariable.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: AppString.appName,
              // onGenerateRoute: Routers.generateRoute,
              routes: const <String, WidgetBuilder>{},
              // home: AppLifecycleReactor(),
              home: getRootWidget(),
              //  home: LoginScreen (),
            ),
          ),
        );
      },
    );
  }

  Widget getRootWidget() {
    log("User logged in==${FirebaseAuth.instance.currentUser != null}");
    return FirebaseAuth.instance.currentUser != null
        ? const AdminHomeSCreen()
        : const AdminLoginScreen();
  }
}

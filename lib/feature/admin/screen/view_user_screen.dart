import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/widget/appbar.dart';
import 'package:get_location/feature/admin/cubit/get_users_list_cubit.dart';
import 'package:get_location/feature/admin/screen/widget/user_list_widget.dart';
import 'package:get_location/feature/auth/model/user_model.dart';

class ViewUserScreen extends StatefulWidget {
  const ViewUserScreen({super.key});

  @override
  State<ViewUserScreen> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends State<ViewUserScreen> {
  GetUsersListCubit getUsersListCubit = GetUsersListCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsersListCubit.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColor.whiteColor,
      appBar: CustomAppBar.backButton(title: "View Users", context: context),
      body: BlocProvider.value(
        value: getUsersListCubit,
        child: BlocBuilder<GetUsersListCubit, List<UserModel>>(
          builder: (context, userList) {
            if (userList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return UserListWidget(
                userList: userList,
              );
            }
          },
        ),
      ),
    );
  }
}

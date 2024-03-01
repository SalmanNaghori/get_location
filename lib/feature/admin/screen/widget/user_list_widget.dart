import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant/color_const.dart';
import '../../../auth/model/user_model.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> userList;
  const UserListWidget({
    super.key,
    required this.userList,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CircleAvatar(
                        backgroundColor: ConstColor.primaryColor,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name: ${userList[index].firstName} ${userList[index].secondName}',
                          style: const TextStyle(
                              fontSize: 25,
                              fontFamily: "chewy",
                              color: ConstColor.primaryColor),
                        ),
                        Text(
                          'Email: ${userList[index].email}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontFamily: "chewy",
                              color: ConstColor.primaryColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              CupertinoIcons.location_solid,
                              color: ConstColor.primaryColor,
                            ),
                            Text(
                              ': ${userList[index].latitude}, '
                              ' ${userList[index].longitude}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "chewy",
                                  color: ConstColor.primaryColor),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),

                // Add more fields as needed
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/storage/shared_pref.dart';

import '../../../core/util/logger.dart';
import '../../auth/model/user_model.dart';

class UserInRangeState {
  List<UserModel> users;
  UserInRangeState(this.users);
}

class UserInRangeCubit extends Cubit<UserInRangeState> {
  UserInRangeCubit() : super(UserInRangeState([]));
  Future<void> fetchData() async {
    try {
      List<UserModel> userList = [];

      FirebaseFirestore.instance
          .collection("admin")
          .doc(SharedPrefUtils.getAdminId())
          .collection('usersInRange')
          .snapshots()
          .listen((event) {
        userList =
            event.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

        if (userList.isNotEmpty) {
          // Emit the list of users to the UI
          emit(UserInRangeState(userList));
          logger.d('User in range data exists: $userList');
        } else {
          // If no documents found, emit an empty list
          emit(UserInRangeState([]));
          logger.w('No documents found in the "usersInRange" collection');
        }
      });
    } catch (e) {
      // Handle errors
      logger.e('Error fetching data: $e');
    }
  }
}

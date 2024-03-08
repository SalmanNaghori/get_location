import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/core/util/logger.dart';

import '../../auth/model/user_model.dart';

class GetUsersListCubit extends Cubit<List<UserModel>> {
  GetUsersListCubit() : super([]);

  Future<void> fetchData() async {
    try {
      // Fetch data from Firebase
      final _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;

      // Retrieve all documents from the "users" collection
      var querySnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      // Convert documents to a list of UserModel
      List<UserModel> userList = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      if (userList.isNotEmpty) {
        // Emit the list of users to the UI
        emit(userList);
        logger.d('Data exists: $userList');
      } else {
        // If no documents found, emit an empty list
        emit([]);
        logger.w('No documents found in the "users" collection');
      }
    } catch (e) {
      // Handle errors
      logger.e('Error fetching data: $e');
    }
  }
}

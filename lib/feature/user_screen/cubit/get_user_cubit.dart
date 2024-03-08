import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_location/feature/auth/model/user_model.dart';

import '../../../core/util/logger.dart';

class FirebaseCubit extends Cubit<List<UserModel>> {
  FirebaseCubit() : super([]);

  Future<void> fetchData() async {
    try {
      final _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;

      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email)
          .get();

      if (snapshot.exists) {
        UserModel userModel = UserModel.fromMap(snapshot.data());
        emit([userModel]);
        logger.d('Data exists: $userModel');
      } else {
        logger.w('Document does not exist');
        emit([]);
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
    }
  }
}

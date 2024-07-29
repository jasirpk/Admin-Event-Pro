import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class EventUsersProfile {
  Stream<QuerySnapshot> getUserProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('isValid', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserDetailById(String uid) async {
    try {
      DocumentSnapshot docSanpshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return docSanpshot;
    } catch (e) {
      log('Error fetching category detail by ID: $e');
      print('Data Can\'t find in database');
      rethrow;
    }
  }
}

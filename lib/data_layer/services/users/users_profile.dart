import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class EventUsersProfile {
  /// The consumer directory behind the chat, notification and checklist
  /// screens.
  ///
  /// Reads `publicProfiles`, not `users`: a consumer's `users` document is
  /// readable only by its owner and by platform admins, so an entrepreneur
  /// cannot query it. `publicProfiles` carries exactly the fields these
  /// screens render and nothing else.
  Stream<QuerySnapshot> getUserProfile() {
    return FirebaseFirestore.instance
        .collection('publicProfiles')
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

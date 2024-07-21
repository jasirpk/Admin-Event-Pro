import 'package:cloud_firestore/cloud_firestore.dart';

class EventMethods {
  Stream<QuerySnapshot> getGeneratedEventsDetails(
      String uid, String EntrepreneurId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .where('EntrepreneurId', isEqualTo: EntrepreneurId)
        .where('isValid', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot?> getEventsById(String uid, String eventId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(eventId)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        print('Event with eventId $eventId not found');
        return null;
      }
    } catch (e) {
      print('Error getting documentId by Id $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }
}

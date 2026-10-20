import 'package:cloud_firestore/cloud_firestore.dart';

class EventMethods {
  /// Bookings this entrepreneur has been handed, for one customer.
  ///
  /// The `isValid` filter stays, and deliberately. It records that the
  /// customer released the booking to the company, and since the consumer
  /// app now writes it true at submission there is no longer a second tap
  /// standing between a new booking and this query — the filter excludes
  /// nothing that has been submitted.
  ///
  /// Dropping it would not widen the result to "newer" bookings; it would
  /// surface the older ones whose customer never handed them over at all.
  ///
  /// It says nothing about acceptance. No entrepreneur accept/reject
  /// workflow exists for bookings, and this flag must not be read as one.
  ///
  /// [uid] is the customer. This query cannot find an entrepreneur's
  /// bookings on its own — see the entrepreneurBookings index design.
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

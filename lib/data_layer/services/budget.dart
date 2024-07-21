import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetTrack {
  Future<void> addRevenue(
      {required String uid,
      required String eveneType,
      required String date,
      required String revenue,
      required String cost,
      required String benefit}) async {
    try {
      CollectionReference subColletionRef = FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .collection('revenues');
      await subColletionRef.add({
        'eventType': eveneType,
        'date': date,
        'totalRevenue': revenue,
        'cost': cost,
        'benefit': benefit
      });
      print('Added revenue detail to collection revenues');
    } catch (e) {
      print('Error adding to revenues $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getBudgetReveneu(String uid) {
    return FirebaseFirestore.instance
        .collection('entrepreneurs')
        .doc(uid)
        .collection('revenues')
        .snapshots();
  }

  Future<DocumentSnapshot?> getBudgetRevenueById(
      String uid, String budgetId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .collection('revenues')
          .doc(budgetId)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        print('Document Id $budgetId not found');
        return null;
      }
    } catch (e) {
      print('Error getting revenue budget id $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }
}

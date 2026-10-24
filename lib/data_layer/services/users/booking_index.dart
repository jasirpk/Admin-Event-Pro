import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:admineventpro/data_layer/models/booking_customer.dart';
import 'package:admineventpro/data_layer/models/booking_detail.dart';
import 'package:admineventpro/data_layer/models/booking_summary.dart';

/// Reads the entrepreneur's own bookings from the `entrepreneurBookings`
/// index.
///
/// This replaced walking a directory of every customer and querying each
/// one's `events` subcollection in turn. That approach needed a global list
/// of consumers to exist at all, which is precisely what it should not need.
///
/// The index is written only by the Media API. Its rules allow a read solely
/// where `entrepreneurId` equals the caller's uid, so the filter below is not
/// a convenience — a query without it is refused outright, and an unfiltered
/// listing is refused too.
class BookingIndexService {
  BookingIndexService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _injectedFirestore = firestore,
        _injectedAuth = auth;

  final FirebaseFirestore? _injectedFirestore;
  final FirebaseAuth? _injectedAuth;

  // Resolved on use rather than in the initializer: touching
  // FirebaseAuth.instance at construction would throw wherever no Firebase
  // app exists, which is every widget test.
  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  static const String collection = 'entrepreneurBookings';

  /// The signed-in entrepreneur, or null when there is no session.
  ///
  /// Read from the auth session, never from a route argument or a field on a
  /// document, so a caller cannot ask for somebody else's bookings.
  String? get currentEntrepreneurUid => _auth.currentUser?.uid;

  /// The bookings addressed to [entrepreneurUid], newest first.
  ///
  /// A single equality filter and no `orderBy`, which Firestore serves from
  /// the single-field index it maintains for `entrepreneurId` automatically.
  /// No composite index is involved, so this query cannot fail with
  /// `failed-precondition` for a missing one.
  ///
  /// Ordering therefore happens here rather than in Firestore. That is a real
  /// trade: the whole result set is fetched and sorted in memory, so it is
  /// correct at this collection's size and would not stay correct under a
  /// server-side `limit`. See [sortedNewestFirst].
  Stream<List<BookingSummary>> watchBookings(String entrepreneurUid) {
    return _firestore
        .collection(collection)
        .where('entrepreneurId', isEqualTo: entrepreneurUid)
        .snapshots()
        .map((snapshot) => sortedNewestFirst(snapshot.docs
            .map((doc) => BookingSummary.fromIndex(doc.id, doc.data()))
            .toList()));
  }

  /// The distinct customers [entrepreneurUid] has bookings with, most
  /// recent first.
  ///
  /// Built from the same owner-filtered index query the Bookings list uses,
  /// so it inherits its authorisation: the rules only return rows whose
  /// `entrepreneurId` is the caller's own. This is deliberately *not* a
  /// directory of every consumer — it is the people this entrepreneur
  /// actually has work with.
  Stream<List<BookingCustomer>> watchCustomers(String entrepreneurUid) {
    return watchBookings(entrepreneurUid).map(BookingCustomer.from);
  }

  /// The source booking behind an index row.
  ///
  /// Reads `users/{customerUid}/events/{eventId}` directly — the one document
  /// the deployed rules let this entrepreneur see, because the booking names
  /// them in `EntrepreneurId`. The customer's account is otherwise closed to
  /// them: the parent user document, their other bookings and an unfiltered
  /// listing of the subcollection are all refused.
  ///
  /// [customerUid] and [eventId] come from the index row, never from user
  /// input, so this cannot be pointed at an arbitrary document — and if it
  /// were, the rules would refuse it.
  ///
  /// Returns null when the booking has been deleted since it was indexed.
  Future<BookingDetail?> fetchDetail({
    required String customerUid,
    required String eventId,
  }) async {
    // A malformed index row would otherwise reach `.doc('')`, which throws
    // ArgumentError inside the request. There is no document to ask for, so
    // this answers like a missing one instead of failing.
    if (customerUid.isEmpty || eventId.isEmpty) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(customerUid)
        .collection('events')
        .doc(eventId)
        .get();

    final data = snapshot.data();

    return data == null ? null : BookingDetail.fromSource(data);
  }

  /// [bookings] newest first, as a new list.
  ///
  /// Replaces the `orderBy('createdAt', descending: true)` that Firestore
  /// used to apply, and has to cope with what a server-side sort never saw:
  /// a row whose `createdAt` is missing or of an unexpected type parses to
  /// null, and null has no place on a timeline. Those rows sort last rather
  /// than being dropped — a booking with a bad timestamp is still a booking,
  /// and hiding it would be worse than showing it at the bottom.
  ///
  /// Ties, including null against null, break on `indexId` so the order is
  /// stable between rebuilds instead of shuffling on every snapshot.
  static List<BookingSummary> sortedNewestFirst(List<BookingSummary> bookings) {
    final sorted = [...bookings];

    sorted.sort((a, b) {
      final at = a.createdAt;
      final bt = b.createdAt;

      if (at == null && bt == null) return a.indexId.compareTo(b.indexId);
      if (at == null) return 1;
      if (bt == null) return -1;

      final byTime = bt.compareTo(at);

      return byTime != 0 ? byTime : a.indexId.compareTo(b.indexId);
    });

    return sorted;
  }
}

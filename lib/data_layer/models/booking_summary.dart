import 'package:cloud_firestore/cloud_firestore.dart';

/// One row of `entrepreneurBookings`, as the Bookings list renders it.
///
/// The index is written by the Media API from the customer's booking, so
/// every field here is a copy made at index time. The booking itself remains
/// the system of record at `sourcePath`.
///
/// Note what is absent. The index carries no customer email or phone — those
/// are deliberately withheld by the server until the access policy is
/// settled — and `clientName`, which the index does carry, is not read here
/// for the same reason. See the Phase 4 report.
///
/// Every field is parsed defensively. These documents are written by a
/// server that may be a version ahead or behind this app, and a single
/// malformed row must degrade to a sparse card rather than take down the
/// whole list.
class BookingSummary {
  const BookingSummary({
    required this.indexId,
    required this.eventId,
    required this.customerUid,
    required this.entrepreneurId,
    required this.sourcePath,
    required this.eventType,
    required this.date,
    required this.time,
    required this.location,
    required this.guestCount,
    required this.imagePath,
    required this.customerSubmitted,
    this.amount,
    this.createdAt,
  });

  /// The document id, `{customerUid}_{eventId}`.
  final String indexId;

  final String eventId;
  final String customerUid;
  final String entrepreneurId;

  /// Where the booking itself lives.
  final String sourcePath;

  final String eventType;
  final String date;
  final String time;
  final String location;
  final String guestCount;

  /// An R2 object key, a legacy HTTPS URL, or empty.
  final String imagePath;

  /// The customer handed the booking over. **Not** an acceptance decision by
  /// this entrepreneur — no such workflow exists.
  final bool customerSubmitted;

  /// The quoted total, when one parsed.
  final double? amount;

  final DateTime? createdAt;

  factory BookingSummary.fromIndex(String indexId, Map<String, dynamic> data) {
    return BookingSummary(
      indexId: indexId,
      eventId: _text(data['eventId']),
      customerUid: _text(data['customerUid']),
      entrepreneurId: _text(data['entrepreneurId']),
      sourcePath: _text(data['sourcePath']),
      eventType: _text(data['eventype']),
      date: _text(data['date']),
      time: _text(data['time']),
      location: _text(data['location']),
      guestCount: _text(data['guestCount']),
      imagePath: _text(data['imageURL']),
      customerSubmitted: data['customerSubmitted'] == true,
      amount: _number(data['sum']),
      createdAt: _time(data['createdAt']),
    );
  }

  /// A string field, or '' — never a failed cast.
  static String _text(dynamic raw) => raw is String ? raw : '';

  /// The total, which the consumer writes as a string and a future writer
  /// might write as a number. Either parses; anything else is simply absent.
  static double? _number(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  /// A Firestore timestamp, tolerating a row written before the field
  /// existed or with an unexpected type.
  static DateTime? _time(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }
}

/// The parts of a booking that live only in the source document.
///
/// The index at `entrepreneurBookings` deliberately carries no contact
/// details, so the card's summary cannot show them. The booking itself does,
/// at `users/{customerUid}/events/{eventId}`, and the deployed rules let the
/// entrepreneur named on that booking read it — one document, theirs, and
/// nothing else in the customer's account.
///
/// Fetched only when a card is opened, so browsing the list never pulls
/// anybody's contact details.
class BookingDetail {
  const BookingDetail({
    required this.clientName,
    required this.email,
    required this.phoneNumber,
    required this.about,
    required this.eventType,
    required this.date,
    required this.time,
    required this.location,
    required this.guestCount,
    required this.imagePath,
    this.amount,
  });

  final String clientName;
  final String email;
  final String phoneNumber;

  /// The customer's description of the event (`eventAbout` in the source).
  final String about;

  final String eventType;
  final String date;
  final String time;
  final String location;
  final String guestCount;
  final String imagePath;
  final double? amount;

  /// Parsed from the source booking.
  ///
  /// Every field is read defensively: this document is written by a separate
  /// app whose schema may move, and a surprise type must leave the field
  /// blank rather than throw while a sheet is opening.
  factory BookingDetail.fromSource(Map<String, dynamic> data) {
    return BookingDetail(
      clientName: _text(data['clientName']),
      email: _text(data['email']),
      phoneNumber: _text(data['phoneNumber']),
      about: _text(data['eventAbout']),
      eventType: _text(data['eventype']),
      date: _text(data['date']),
      time: _text(data['time']),
      location: _text(data['location']),
      guestCount: _text(data['guestCount']),
      imagePath: _text(data['imageURL']),
      amount: _number(data['sum']),
    );
  }

  static String _text(dynamic raw) => raw is String ? raw.trim() : '';

  static double? _number(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}

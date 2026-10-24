import 'package:admineventpro/data_layer/models/booking_summary.dart';

/// One customer the entrepreneur has a booking with, as the Messages list
/// shows them.
///
/// Collapsed from the booking index: a customer who has booked three times
/// is one person to talk to, not three. Carries only what a conversation row
/// needs — no contact details, which the index does not hold anyway.
class BookingCustomer {
  const BookingCustomer({
    required this.customerUid,
    required this.name,
    required this.imagePath,
    this.lastBookingAt,
  });

  final String customerUid;

  /// `clientName` from the most recent booking, or '' when it is absent.
  final String name;

  /// The most recent booking's image. Not an avatar — the index carries no
  /// customer photo — so the list falls back to the person placeholder.
  final String imagePath;

  final DateTime? lastBookingAt;

  /// Distinct customers across [bookings], newest booking first.
  ///
  /// [bookings] arrives already sorted newest-first, so the first row seen
  /// for a customer is their most recent and the rest are skipped. That also
  /// makes the resulting order stable.
  static List<BookingCustomer> from(List<BookingSummary> bookings) {
    final seen = <String>{};
    final customers = <BookingCustomer>[];

    for (final booking in bookings) {
      // A malformed row with no customer cannot be messaged, and would
      // derive a nonsense chat id, so it is skipped rather than shown.
      if (booking.customerUid.isEmpty) continue;
      if (!seen.add(booking.customerUid)) continue;

      customers.add(BookingCustomer(
        customerUid: booking.customerUid,
        name: booking.clientName,
        imagePath: booking.imagePath,
        lastBookingAt: booking.createdAt,
      ));
    }

    return customers;
  }
}

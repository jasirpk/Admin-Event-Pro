import 'dart:developer' as developer;

import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/models/booking_detail.dart';
import 'package:admineventpro/data_layer/models/booking_summary.dart';
import 'package:admineventpro/data_layer/services/users/booking_index.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// The bookings addressed to the signed-in entrepreneur.
///
/// Replaced a screen that listed every consumer on the platform and drilled
/// into one customer at a time. Nothing here reads `publicProfiles`, and
/// nothing reads `users`: the whole list comes from `entrepreneurBookings`,
/// filtered to this entrepreneur by a rule rather than by the client.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key, this.service, this.bookings});

  /// Overridden in tests. Defaults to the real Firestore-backed service.
  final BookingIndexService? service;

  /// Overridden in tests, in place of the Firestore stream.
  final Stream<List<BookingSummary>>? bookings;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // An injected stream short-circuits the service entirely, so a test
    // never reaches Firebase.
    Stream<List<BookingSummary>>? stream = bookings;

    if (stream == null) {
      final index = service ?? BookingIndexService();
      final uid = index.currentEntrepreneurUid;

      // The uid comes from the session. There is no route argument, no field
      // on a document and no widget parameter that could name another
      // entrepreneur.
      stream = uid == null ? null : index.watchBookings(uid);
    }

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Bookings'),
      body: stream == null
          ? const _Message(
              icon: Icons.lock_outline,
              text: 'Sign in to see the events booked with you.',
            )
          : StreamBuilder<List<BookingSummary>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerAllSubcategories(
                      screenHeight: screenHeight, screenWidth: screenWidth);
                }

                if (snapshot.hasError) {
                  // Reported, never worked around. The old screen could fall
                  // back to listing every customer; this one must not, so a
                  // failed query stays a failed query.
                  return _errorView(snapshot.error!);
                }

                final bookings = snapshot.data ?? const <BookingSummary>[];

                if (bookings.isEmpty) {
                  return const _Message(
                    icon: Icons.event_busy,
                    text: 'No bookings yet.\nEvents booked with you will '
                        'appear here.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => _BookingCard(
                    booking: bookings[index],
                    service: service,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                );
              },
            ),
    );
  }
}

/// Turns a query failure into something the user can act on, and a line a
/// developer can diagnose from.
///
/// The two failures that matter here are indistinguishable on screen but have
/// completely different causes, and telling them apart from a bug report was
/// previously impossible: every failure rendered one generic sentence and
/// logged nothing.
///
/// Only the error's code and runtime type are logged. No token, no document
/// contents, no customer data — a Firestore error message can quote the
/// query, so it is deliberately not interpolated.
_Message _errorView(Object error) {
  final String code = error is FirebaseException ? error.code : '';

  developer.log(
    'Bookings query failed (code: ${code.isEmpty ? 'none' : code}, '
    'type: ${error.runtimeType})',
    name: 'Bookings',
  );

  switch (code) {
    case 'permission-denied':
      // Firestore rules refused the read. The query is correct; the rules
      // deployed against this project do not allow it.
      return const _Message(
        icon: Icons.lock_outline,
        text: 'Your bookings could not be opened because access is blocked.\n'
            'Please contact support.',
      );

    case 'failed-precondition':
      // Usually a missing composite index, but not necessarily — the code
      // covers other unmet preconditions too, so this does not assert a
      // cause the user cannot verify.
      return const _Message(
        icon: Icons.hourglass_empty,
        text: 'Your bookings are not ready yet.\n'
            'Please try again in a few minutes, or contact support if this '
            'continues.',
      );

    default:
      return const _Message(
        icon: Icons.error_outline,
        text: 'Could not load your bookings. Pull down to try again.',
      );
  }
}

/// One booking, summarised. Opens the full booking when tapped.
///
/// Stateful only to hold the open guard: two taps landing in the same frame
/// would otherwise push two sheets and fire two fetches, leaving the second
/// stacked behind the first.
class _BookingCard extends StatefulWidget {
  const _BookingCard({
    required this.booking,
    required this.service,
    required this.screenHeight,
    required this.screenWidth,
  });

  final BookingSummary booking;
  final BookingIndexService? service;
  final double screenHeight;
  final double screenWidth;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;

    try {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _DetailSheet(
          booking: widget.booking,
          service: widget.service ?? BookingIndexService(),
        ),
      );
    } finally {
      // Reset once the sheet closes, however it closed, so the card stays
      // tappable for the next time.
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;

    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // imageURL is an R2 object key since the migration, so it needs
              // signing; MediaImage tells a key from a legacy URL.
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MediaImage(
                  imagePath: booking.imagePath,
                  placeholder: AssetImage(Assigns.placeHolderImage),
                  builder: (context, image) => Container(
                    width: screenWidth * 0.24,
                    height: screenHeight * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      image: image == null
                          ? null
                          : DecorationImage(image: image, fit: BoxFit.cover),
                    ),
                    child: image == null
                        ? const Icon(Icons.image_not_supported,
                            color: Colors.white38)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clientName.isNotEmpty
                          ? booking.clientName
                          : booking.eventType.isEmpty
                              ? 'Untitled event'
                              : booking.eventType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (booking.clientName.isNotEmpty)
                      Text(
                        booking.eventType.isEmpty
                            ? 'Untitled event'
                            : booking.eventType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                      ),
                    const SizedBox(height: 6),
                    _Line(
                      icon: Icons.calendar_today,
                      text: [booking.date, booking.time]
                          .where((part) => part.isNotEmpty)
                          .join(' · '),
                    ),
                    _Line(icon: Icons.location_on, text: booking.location),
                    _Line(
                      icon: Icons.people_outline,
                      text: booking.guestCount.isEmpty
                          ? ''
                          : '${booking.guestCount} guests',
                    ),
                    _Line(
                      icon: Icons.currency_rupee,
                      text: booking.amount == null
                          ? ''
                          : booking.amount!.toStringAsFixed(0),
                    ),
                    const SizedBox(height: 6),
                    // Says what it means: the customer sent it. It is not an
                    // acceptance by this entrepreneur.
                    _Chip(submitted: booking.customerSubmitted),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// The full booking: contact details and everything the index does not carry.
///
/// Opens on the summary already in hand, then fetches the source booking for
/// the rest. The summary stays visible while that loads, so the sheet is
/// never blank and a fetch failure still leaves a useful view.
class _DetailSheet extends StatefulWidget {
  const _DetailSheet({required this.booking, required this.service});

  final BookingSummary booking;
  final BookingIndexService service;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late final Future<BookingDetail?> _detail = widget.service.fetchDetail(
    customerUid: widget.booking.customerUid,
    eventId: widget.booking.eventId,
  );

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              b.eventType.isEmpty ? 'Untitled event' : b.eventType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _Chip(submitted: b.customerSubmitted),
            const SizedBox(height: 20),

            // The source booking is the fresher copy: the index is written
            // once and never refreshed when a customer edits their booking.
            // So every shared field prefers the fetched value and falls back
            // to the indexed one — a missing source field must never blank
            // out a value the index still holds.
            FutureBuilder<BookingDetail?>(
              future: _detail,
              builder: (context, snapshot) {
                final detail = snapshot.data;
                final waiting =
                    snapshot.connectionState == ConnectionState.waiting;

                final imagePath = _prefer(detail?.imagePath, b.imagePath);
                final amount = detail?.amount ?? b.amount;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagePath.isNotEmpty) ...[
                      // Same component and key format as the card: an R2
                      // object key is signed, a legacy HTTPS URL is used
                      // as-is. No new URL scheme here.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MediaImage(
                          imagePath: imagePath,
                          placeholder: AssetImage(Assigns.placeHolderImage),
                          builder: (context, image) => Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              image: image == null
                                  ? null
                                  : DecorationImage(
                                      image: image, fit: BoxFit.cover),
                            ),
                            child: image == null
                                ? const Icon(Icons.image_not_supported,
                                    color: Colors.white38)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const _SectionTitle('Event'),
                    _Row(label: 'Date', value: _prefer(detail?.date, b.date)),
                    _Row(label: 'Time', value: _prefer(detail?.time, b.time)),
                    _Row(
                      label: 'Location',
                      value: _prefer(detail?.location, b.location),
                    ),
                    _Row(
                      label: 'Guests',
                      value: _guests(_prefer(detail?.guestCount, b.guestCount)),
                    ),
                    _Row(
                      label: 'Estimate',
                      value: amount == null ? '' : amount.toStringAsFixed(0),
                    ),
                    if (detail != null && detail.about.isNotEmpty) ...[
                      const _SectionTitle('About this event'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          detail.about,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    if (waiting)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (snapshot.hasError)
                      _Note(_detailError(snapshot.error!))
                    else if (detail == null)
                      const _Note(
                        'This booking is no longer available. The customer '
                        'may have deleted it.',
                      )
                    else ...[
                      const _SectionTitle('Customer'),
                      // A blank field is said to be blank rather than shown
                      // as an empty value that could be mistaken for a real
                      // one.
                      _Row(
                        label: 'Name',
                        value: detail.clientName,
                        fallback: 'Not provided',
                      ),
                      _Row(
                        label: 'Email',
                        value: detail.email,
                        fallback: 'Not provided',
                      ),
                      _Row(
                        label: 'Phone',
                        value: detail.phoneNumber,
                        fallback: 'Not provided',
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The fetched value when it has one, otherwise the indexed value.
///
/// The index is the older copy but never an empty one for a field it holds,
/// so a source document that has lost a field must not blank the row.
String _prefer(String? fetched, String indexed) =>
    (fetched != null && fetched.isNotEmpty) ? fetched : indexed;

String _guests(String count) => count.isEmpty ? '' : '$count guests';

/// What to tell the entrepreneur when the source booking will not load.
///
/// Separates a refusal, which retrying cannot fix, from a transient fault,
/// which it can. Only the code and type are logged — never the message,
/// which can quote the document, and never a contact field.
String _detailError(Object error) {
  final String code = error is FirebaseException ? error.code : '';

  developer.log(
    'Booking detail fetch failed (code: ${code.isEmpty ? 'none' : code}, '
    'type: ${error.runtimeType})',
    name: 'Bookings',
  );

  switch (code) {
    case 'permission-denied':
      return 'You do not have access to this booking\'s details. '
          'Please contact support.';

    case 'unavailable':
    case 'deadline-exceeded':
    case 'cancelled':
      return 'Could not reach the server. Check your connection and open '
          'this booking again.';

    default:
      return 'These details could not be loaded. Please open this booking '
          'again in a moment.';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: myColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// A labelled value. Hidden entirely when empty, unless a [fallback] says
/// explicitly that the field was not provided.
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.fallback});

  final String label;
  final String value;
  final String? fallback;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty && fallback == null) return const SizedBox.shrink();

    final missing = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: SelectableText(
              missing ? fallback! : value,
              style: TextStyle(
                color: missing ? Colors.white30 : Colors.white,
                fontSize: 14,
                fontStyle: missing ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
    );
  }
}

/// One icon-and-value line, omitted entirely when there is no value.
class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.submitted});

  final bool submitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: submitted ? myColor : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        submitted ? 'Sent by customer' : 'Not sent yet',
        style: TextStyle(
          color: submitted ? Colors.black : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Empty, error and signed-out states share one shape.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

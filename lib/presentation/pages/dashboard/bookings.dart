import 'dart:developer' as developer;

import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
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

/// One booking, summarised.
///
/// Not tappable. The old list opened a customer-scoped screen that needs the
/// consumer directory, and the existing event detail screen requires the
/// customer's email and phone — neither is an appropriate destination for a
/// booking, so this phase offers no navigation at all rather than a
/// misleading one.
class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.screenHeight,
    required this.screenWidth,
  });

  final BookingSummary booking;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 12),
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
                    booking.eventType.isEmpty
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
          ],
        ),
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

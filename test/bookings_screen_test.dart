import 'dart:async';

import 'package:admineventpro/data_layer/models/booking_summary.dart';
import 'package:admineventpro/data_layer/services/users/booking_index.dart';
import 'package:admineventpro/presentation/pages/dashboard/bookings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The entrepreneur Bookings screen and the model behind it.
///
/// The Firestore stream is injected, so these run offline with no Firebase
/// app. The query's own constraints cannot be asserted here — see the report
/// for how they are covered instead.

/// A service that reports a uid without touching FirebaseAuth.
class FakeIndexService extends BookingIndexService {
  FakeIndexService(this._uid);

  final String? _uid;

  @override
  String? get currentEntrepreneurUid => _uid;
}

Map<String, dynamic> indexRow({
  String eventType = 'Wedding',
  String date = '01/01/2026',
  String time = '6:00 PM',
  String location = 'Kozhikode',
  String guestCount = '120',
  Object? sum = '90000',
  bool customerSubmitted = true,
}) =>
    {
      'entrepreneurId': 'ent-1',
      'customerUid': 'cust-1',
      'eventId': 'ev-1',
      'sourcePath': 'users/cust-1/events/ev-1',
      'customerSubmitted': customerSubmitted,
      'eventype': eventType,
      'date': date,
      'time': time,
      'location': location,
      'guestCount': guestCount,
      'sum': sum,
      'imageURL': '',
      'clientName': 'A Customer',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    };

BookingSummary summary([Map<String, dynamic>? over]) =>
    BookingSummary.fromIndex('cust-1_ev-1', over ?? indexRow());

Future<void> pumpScreen(
  WidgetTester tester, {
  Stream<List<BookingSummary>>? stream,
  BookingIndexService? service,
}) async {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: BookingsScreen(bookings: stream, service: service),
  ));
}

void main() {
  group('the model parses defensively', () {
    test('a complete row maps every displayed field', () {
      final b = summary();

      expect(b.indexId, 'cust-1_ev-1');
      expect(b.eventId, 'ev-1');
      expect(b.customerUid, 'cust-1');
      expect(b.entrepreneurId, 'ent-1');
      expect(b.sourcePath, 'users/cust-1/events/ev-1');
      expect(b.eventType, 'Wedding');
      expect(b.location, 'Kozhikode');
      expect(b.amount, 90000);
      expect(b.customerSubmitted, isTrue);
      expect(b.createdAt, DateTime(2026, 1, 1));
    });

    test('an empty row yields blanks rather than throwing', () {
      final b = BookingSummary.fromIndex('id', const {});

      expect(b.eventType, '');
      expect(b.location, '');
      expect(b.amount, isNull);
      expect(b.createdAt, isNull);
      expect(b.customerSubmitted, isFalse);
    });

    test('malformed values are ignored, not cast', () {
      final b = BookingSummary.fromIndex('id', {
        'eventype': 42,
        'date': null,
        'sum': 'not a number',
        'createdAt': 'yesterday',
        'customerSubmitted': 'true',
        'guestCount': ['x'],
      });

      expect(b.eventType, '');
      expect(b.date, '');
      expect(b.amount, isNull);
      expect(b.createdAt, isNull);
      expect(b.customerSubmitted, isFalse, reason: 'only a real bool counts');
      expect(b.guestCount, '');
    });

    test('a numeric sum parses as well as a string one', () {
      expect(BookingSummary.fromIndex('id', {'sum': 1500}).amount, 1500);
      expect(BookingSummary.fromIndex('id', {'sum': 1500.5}).amount, 1500.5);
      expect(BookingSummary.fromIndex('id', {'sum': '1500'}).amount, 1500);
    });
  });

  group('local ordering replaces the removed orderBy', () {
    BookingSummary at(String id, DateTime? created) =>
        BookingSummary.fromIndex(id, {
          'eventype': id,
          if (created != null) 'createdAt': Timestamp.fromDate(created),
        });

    List<String> idsOf(List<BookingSummary> list) =>
        BookingIndexService.sortedNewestFirst(list)
            .map((b) => b.indexId)
            .toList();

    test('newest first', () {
      expect(
        idsOf([
          at('old', DateTime(2026, 1, 1)),
          at('newest', DateTime(2026, 6, 1)),
          at('middle', DateTime(2026, 3, 1)),
        ]),
        ['newest', 'middle', 'old'],
      );
    });

    test('a missing timestamp sorts last, never dropped', () {
      final sorted = idsOf([
        at('undated', null),
        at('older', DateTime(2026, 1, 1)),
        at('newer', DateTime(2026, 5, 1)),
      ]);

      expect(sorted, ['newer', 'older', 'undated']);
      expect(sorted, hasLength(3), reason: 'a bad timestamp loses no booking');
    });

    test('a malformed timestamp is treated as missing', () {
      final malformed =
          BookingSummary.fromIndex('bad', {'createdAt': 'yesterday'});

      expect(malformed.createdAt, isNull);
      expect(
        idsOf([malformed, at('dated', DateTime(2026, 1, 1))]),
        ['dated', 'bad'],
      );
    });

    test('equal timestamps break on id, so the order is stable', () {
      final when = DateTime(2026, 2, 2);
      final forwards = idsOf([at('b', when), at('a', when), at('c', when)]);
      final backwards = idsOf([at('c', when), at('b', when), at('a', when)]);

      expect(forwards, ['a', 'b', 'c']);
      expect(backwards, forwards, reason: 'input order must not matter');
    });

    test('all-undated rows keep a deterministic order', () {
      expect(idsOf([at('z', null), at('a', null), at('m', null)]),
          ['a', 'm', 'z']);
    });

    test('the input list is not mutated', () {
      final input = [
        at('a', DateTime(2026, 1, 1)),
        at('b', DateTime(2026, 9, 1))
      ];
      BookingIndexService.sortedNewestFirst(input);

      expect(input.map((b) => b.indexId), ['a', 'b']);
    });

    test('an empty list sorts to empty', () {
      expect(BookingIndexService.sortedNewestFirst([]), isEmpty);
    });

    testWidgets('the screen renders newest first', (tester) async {
      await pumpScreen(tester,
          stream: Stream.value(BookingIndexService.sortedNewestFirst([
            at('Older', DateTime(2026, 1, 1)),
            at('Undated', null),
            at('Newest', DateTime(2026, 8, 1)),
          ])));
      await tester.pumpAndSettle();

      final newest = tester.getTopLeft(find.text('Newest')).dy;
      final older = tester.getTopLeft(find.text('Older')).dy;
      final undated = tester.getTopLeft(find.text('Undated')).dy;

      expect(newest, lessThan(older));
      expect(older, lessThan(undated));
    });
  });

  group('screen states', () {
    testWidgets('loading', (tester) async {
      await pumpScreen(tester,
          stream: StreamController<List<BookingSummary>>().stream);
      await tester.pump();

      expect(
          find.text('No bookings yet.\nEvents booked with you will '
              'appear here.'),
          findsNothing);
      expect(find.textContaining('Could not load'), findsNothing);
    });

    testWidgets('empty', (tester) async {
      await pumpScreen(tester, stream: Stream.value(const <BookingSummary>[]));
      await tester.pumpAndSettle();

      expect(find.textContaining('No bookings yet'), findsOneWidget);
    });

    testWidgets('an error never falls back to any other list', (tester) async {
      await pumpScreen(tester,
          stream: Stream<List<BookingSummary>>.error(
              FirebaseException(plugin: 'cloud_firestore', code: 'unknown')));
      await tester.pumpAndSettle();

      expect(
          find.textContaining('Could not load your bookings'), findsOneWidget);
      expect(find.textContaining('No bookings yet'), findsNothing);
    });

    testWidgets('signed out, with no query attempted', (tester) async {
      await pumpScreen(tester, service: FakeIndexService(null));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign in to see'), findsOneWidget);
    });

    testWidgets('populated', (tester) async {
      await pumpScreen(tester, stream: Stream.value([summary()]));
      await tester.pumpAndSettle();

      expect(find.text('Wedding'), findsOneWidget);
      expect(find.textContaining('01/01/2026'), findsOneWidget);
      expect(find.text('Kozhikode'), findsOneWidget);
      expect(find.text('120 guests'), findsOneWidget);
      expect(find.text('90000'), findsOneWidget);
    });
  });

  group('error states are told apart', () {
    Future<void> pumpError(WidgetTester tester, Object error) async {
      await pumpScreen(tester,
          stream: Stream<List<BookingSummary>>.error(error));
      await tester.pumpAndSettle();
    }

    testWidgets('permission-denied says access is blocked', (tester) async {
      await pumpError(
          tester,
          FirebaseException(
              plugin: 'cloud_firestore', code: 'permission-denied'));

      expect(find.textContaining('access is blocked'), findsOneWidget);
      expect(find.textContaining('contact support'), findsOneWidget);
      expect(find.textContaining('not ready yet'), findsNothing);
    });

    testWidgets('failed-precondition says not ready, without blaming an index',
        (tester) async {
      await pumpError(
          tester,
          FirebaseException(
              plugin: 'cloud_firestore', code: 'failed-precondition'));

      expect(find.textContaining('not ready yet'), findsOneWidget);
      expect(find.textContaining('try again in a few minutes'), findsOneWidget);
      // It is usually a missing index, but the code covers other causes and
      // the user cannot verify it, so the copy must not assert one.
      expect(find.textContaining('index'), findsNothing);
      expect(find.textContaining('access is blocked'), findsNothing);
    });

    testWidgets('another Firebase code falls through to the generic message',
        (tester) async {
      await pumpError(tester,
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));

      expect(
          find.textContaining('Could not load your bookings'), findsOneWidget);
      expect(find.textContaining('access is blocked'), findsNothing);
      expect(find.textContaining('not ready yet'), findsNothing);
    });

    testWidgets('a non-Firebase error is generic too', (tester) async {
      await pumpError(tester, StateError('boom'));

      expect(
          find.textContaining('Could not load your bookings'), findsOneWidget);
    });

    testWidgets('no error state ever shows a list of any kind', (tester) async {
      for (final error in <Object>[
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
        FirebaseException(
            plugin: 'cloud_firestore', code: 'failed-precondition'),
        StateError('boom'),
      ]) {
        await pumpError(tester, error);

        expect(find.byType(Card), findsNothing,
            reason: 'no booking or customer rows on an error');
        expect(find.textContaining('No bookings yet'), findsNothing);
      }
    });
  });

  group('privacy and status wording', () {
    testWidgets('no customer name, email or phone is shown', (tester) async {
      await pumpScreen(tester, stream: Stream.value([summary()]));
      await tester.pumpAndSettle();

      expect(find.textContaining('A Customer'), findsNothing,
          reason: 'clientName is withheld pending the access policy');
      expect(find.textContaining('@'), findsNothing);
    });

    testWidgets('the chip says the customer sent it, not that it is accepted',
        (tester) async {
      await pumpScreen(tester, stream: Stream.value([summary()]));
      await tester.pumpAndSettle();

      expect(find.text('Sent by customer'), findsOneWidget);
      expect(find.textContaining('Accept'), findsNothing);
      expect(find.textContaining('Approve'), findsNothing);
      expect(find.textContaining('Confirmed'), findsNothing);
    });

    testWidgets('an unsent booking is labelled honestly', (tester) async {
      await pumpScreen(tester,
          stream: Stream.value([summary(indexRow(customerSubmitted: false))]));
      await tester.pumpAndSettle();

      expect(find.text('Not sent yet'), findsOneWidget);
    });
  });

  group('missing fields degrade the card, not the list', () {
    testWidgets('a sparse booking still renders', (tester) async {
      await pumpScreen(tester,
          stream: Stream.value([
            BookingSummary.fromIndex('id', const {'eventype': ''})
          ]));
      await tester.pumpAndSettle();

      expect(find.text('Untitled event'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one sparse row beside a complete one', (tester) async {
      await pumpScreen(tester,
          stream: Stream.value([
            summary(),
            BookingSummary.fromIndex('id2', const {}),
          ]));
      await tester.pumpAndSettle();

      expect(find.text('Wedding'), findsOneWidget);
      expect(find.text('Untitled event'), findsOneWidget);
    });
  });

  group('no navigation is offered', () {
    testWidgets('a card is not tappable', (tester) async {
      await pumpScreen(tester, stream: Stream.value([summary()]));
      await tester.pumpAndSettle();

      // The old list opened a customer-scoped screen; nothing here does.
      // Scoped to the card: a ListView carries its own GestureDetector for
      // scrolling, which says nothing about the card being tappable.
      expect(
        find.descendant(of: find.byType(Card), matching: find.byType(InkWell)),
        findsNothing,
      );
      expect(
        find.descendant(
            of: find.byType(Card), matching: find.byType(GestureDetector)),
        findsNothing,
      );
    });
  });

  test('the service names the index collection', () {
    expect(BookingIndexService.collection, 'entrepreneurBookings');
  });
}

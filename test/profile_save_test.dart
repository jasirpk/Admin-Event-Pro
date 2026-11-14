import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/data_layer/services/profile_api_service.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the body `saveProfile` builds instead of calling the API.
///
/// The arguments are the request: `ProfileApiService.updateProfile` puts
/// every non-null one into the PATCH payload and leaves every null one out,
/// so `containsKey` here is exactly "the key went on the wire".
class _RecordingApi extends ProfileApiService {
  Map<String, dynamic>? payload;

  @override
  Future<String> updateProfile({
    String? companyName,
    String? description,
    String? website,
    String? phoneNumber,
    String? emailAddress,
    String? profileImage,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? links,
  }) async {
    payload = <String, dynamic>{
      if (companyName != null) 'companyName': companyName,
      if (description != null) 'description': description,
      if (website != null) 'website': website,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (emailAddress != null) 'emailAddress': emailAddress,
      if (profileImage != null) 'profileImage': profileImage,
      if (images != null) 'images': images,
      if (links != null) 'links': links,
    };
    return '2026-11-12T00:00:00.000Z';
  }
}

/// Captures what the editor dispatches without running a real save.
class _RecordingBloc extends ProfileBloc {
  final List<ProfileEvent> events = [];

  @override
  void add(ProfileEvent event) => events.add(event);
}

Future<String> saveWith({
  required _RecordingApi api,
  String website = '',
  List<PortfolioRow> portfolio = const [],
  List<String> links = const [],
}) {
  return UserProfile(api: api).saveProfile(
    companyName: 'Acme Events',
    about: 'We run weddings and corporate events.',
    phoneNumber: '9876543210',
    emailAddress: 'hello@acme.test',
    website: website,
    portfolio: portfolio,
    links: links,
  );
}

void main() {
  group('the website has three states', () {
    test('a new URL replaces the stored one', () async {
      final api = _RecordingApi();
      await saveWith(api: api, website: 'https://new.test');

      expect(api.payload!['website'], 'https://new.test');
    });

    test("a cleared field is sent as '', which the API reads as a removal",
        () async {
      // The regression. Sending null omitted the key, and the backend read
      // that as "leave it alone", so the old website survived the save.
      final api = _RecordingApi();
      await saveWith(api: api, website: '');

      expect(api.payload!.containsKey('website'), isTrue);
      expect(api.payload!['website'], '');
    });

    test('a whitespace-only field is a clear, not a value', () async {
      final api = _RecordingApi();
      await saveWith(api: api, website: '   ');

      expect(api.payload!['website'], '');
    });

    test('an untrimmed website is trimmed, as the API requires', () async {
      final api = _RecordingApi();
      await saveWith(api: api, website: '  https://acme.test  ');

      expect(api.payload!['website'], 'https://acme.test');
    });

    test('a caller with no opinion omits the key entirely', () async {
      // The third state, reachable through the transport: null != ''.
      final api = _RecordingApi();
      await api.updateProfile(companyName: 'Acme Events');

      expect(api.payload!.containsKey('website'), isFalse);
    });
  });

  group('saving with the four required fields and nothing else', () {
    test('the save completes rather than throwing', () async {
      final api = _RecordingApi();
      await expectLater(saveWith(api: api), completes);
    });

    test('the four required fields are all present', () async {
      final api = _RecordingApi();
      await saveWith(api: api);

      expect(api.payload!['companyName'], 'Acme Events');
      expect(
          api.payload!['description'], 'We run weddings and corporate events.');
      expect(api.payload!['phoneNumber'], '9876543210');
      expect(api.payload!['emailAddress'], 'hello@acme.test');
    });

    test('no avatar means no profileImage key', () async {
      final api = _RecordingApi();
      await saveWith(api: api);

      expect(api.payload!.containsKey('profileImage'), isFalse);
    });

    test('an empty portfolio and no links are sent as empty arrays', () async {
      // Verified against the real server validator: it accepts [] for both,
      // so these stay in the request and a removal still reaches Firestore.
      final api = _RecordingApi();
      await saveWith(api: api);

      expect(api.payload!['images'], isEmpty);
      expect(api.payload!['links'], isEmpty);
    });
  });

  group('clearing the website leaves everything else alone', () {
    test('every other field is sent exactly as it was', () async {
      final api = _RecordingApi();
      await saveWith(
        api: api,
        website: '',
        links: ['https://instagram.com/acme'],
        portfolio: [PortfolioRow(existingRef: 'profile_portfolio/a.jpg')],
      );

      expect(api.payload!['website'], '');
      expect(api.payload!['companyName'], 'Acme Events');
      expect(
          api.payload!['description'], 'We run weddings and corporate events.');
      expect(api.payload!['phoneNumber'], '9876543210');
      expect(api.payload!['emailAddress'], 'hello@acme.test');
      expect(api.payload!['links'], [
        {'link': 'https://instagram.com/acme'}
      ]);
      expect(api.payload!['images'], [
        {'image': 'profile_portfolio/a.jpg'}
      ]);
      expect(api.payload!.containsKey('profileImage'), isFalse);
    });

    test('links are sent in the stored shape', () async {
      final api = _RecordingApi();
      await saveWith(api: api, links: ['https://instagram.com/acme']);

      expect(api.payload!['links'], [
        {'link': 'https://instagram.com/acme'}
      ]);
    });

    test('an untouched portfolio row keeps its stored reference', () async {
      final api = _RecordingApi();
      await saveWith(
        api: api,
        portfolio: [PortfolioRow(existingRef: 'profile_portfolio/a.jpg')],
      );

      expect(api.payload!['images'], [
        {'image': 'profile_portfolio/a.jpg'}
      ]);
    });
  });

  group('the editor lets the save through', () {
    testWidgets('four required fields and every optional one empty',
        (tester) async {
      final bloc = _RecordingBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: bloc,
          child: const ProfileScreen(
            companyName: 'Acme Events',
            description: 'We run weddings and corporate events.',
            phoneNumber: '9876543210',
            email: 'hello@acme.test',
            // No website, no avatar, no portfolio, no links.
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final save = find.text('Save Details');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      // Reaching the bloc at all is the point: validation did not stop it.
      expect(bloc.events, hasLength(1));
      final event = bloc.events.single as SaveProfile;
      expect(event.companyName, 'Acme Events');
      expect(event.phoneNumber, '9876543210');
      expect(event.emailAddress, 'hello@acme.test');
      expect(event.website, isEmpty);
      expect(event.portfolio, isEmpty);
      expect(event.links, isEmpty);

      expect(find.text('Please fill all the required fields'), findsNothing);
    });

    testWidgets('clearing a stored website still saves', (tester) async {
      final bloc = _RecordingBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: bloc,
          child: const ProfileScreen(
            companyName: 'Acme Events',
            description: 'We run weddings and corporate events.',
            phoneNumber: '9876543210',
            email: 'hello@acme.test',
            website: 'https://old.test',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.text('https://old.test'), '');
      await tester.pumpAndSettle();

      final save = find.text('Save Details');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(bloc.events, hasLength(1));
      expect((bloc.events.single as SaveProfile).website, isEmpty);
      expect(find.text('Please fill all the required fields'), findsNothing);
    });

    testWidgets('a missing required field still stops the save',
        (tester) async {
      final bloc = _RecordingBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: bloc,
          child: const ProfileScreen(
            companyName: 'Acme Events',
            description: 'We run weddings and corporate events.',
            phoneNumber: '9876543210',
            email: 'not-an-email',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final save = find.text('Save Details');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(bloc.events, isEmpty);
      expect(find.text('Please fill all the required fields'), findsOneWidget);
    });
  });
}

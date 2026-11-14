import 'dart:async';

import 'package:admineventpro/bussiness_layer/repos/submit_vendor_dialog.dart';
import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// A profile that would pass the editor's own save check: the four required
/// fields, and the optional ones filled in too.
Map<String, dynamic> completeProfile() => <String, dynamic>{
      'companyName': 'Tathkarah Events',
      'description': 'We run weddings and corporate events.',
      'phoneNumber': '9876543210',
      'emailAddress': 'hello@example.com',
      'website': 'https://example.com',
      'profileImage': 'profile_images/abc.jpg',
      'links': [
        {'link': 'https://instagram.com/example'}
      ],
      'images': [
        {'image': 'profile_images/portfolio.jpg'}
      ],
    };

/// The same four required fields, with every optional one absent.
Map<String, dynamic> barebonesProfile() => <String, dynamic>{
      'companyName': 'Tathkarah Events',
      'description': 'We run weddings and corporate events.',
      'phoneNumber': '9876543210',
      'emailAddress': 'hello@example.com',
    };

/// Hands back a fixed profile, or holds the read open until released.
class _StubProfile extends UserProfile {
  _StubProfile(this.data, {this.gate, this.failure});

  final Map<String, dynamic>? data;
  final Completer<void>? gate;
  final Object? failure;

  int reads = 0;

  @override
  Future<Map<String, dynamic>?> getProfileData(String uid) async {
    reads++;
    if (gate != null) await gate!.future;
    if (failure != null) throw failure!;
    return data;
  }
}

/// Records submissions instead of writing to Firestore.
class _SpyVendor extends GeneratedVendor {
  final List<String> submitted = [];

  @override
  Future<void> updateIsValidField(
    String uid,
    String documentId, {
    required bool isSumbit,
  }) async {
    submitted.add('$documentId:$isSumbit');
  }
}

/// A host app GetX can push dialogs and routes onto. The bloc sits in
/// `builder` rather than `home` so pushed routes inherit it too.
Widget host() => GetMaterialApp(
      builder: (context, child) => BlocProvider(
        create: (_) => ProfileBloc(),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const Scaffold(body: Text('templates')),
    );

void main() {
  setUp(resetSubmissionsInFlight);

  group('what counts as a registered profile', () {
    test('the four required fields make a profile registered', () {
      expect(missingStoredProfileFields(completeProfile()), isEmpty);
      expect(isStoredProfileComplete(completeProfile()), isTrue);
    });

    test('the four required fields are enough on their own', () {
      // No profile image, no website, no social links, no portfolio.
      expect(missingStoredProfileFields(barebonesProfile()), isEmpty);
      expect(isStoredProfileComplete(barebonesProfile()), isTrue);
    });

    test('no profile document at all is missing all four', () {
      expect(
        missingStoredProfileFields(null),
        ['Company name', 'About us', 'Phone number', 'Email address'],
      );
    });

    test('an empty document is missing all four', () {
      expect(missingStoredProfileFields(<String, dynamic>{}).length, 4);
    });

    test('a missing company name is incomplete', () {
      final profile = barebonesProfile()..remove('companyName');
      expect(missingStoredProfileFields(profile), ['Company name']);
      expect(isStoredProfileComplete(profile), isFalse);
    });

    test('a missing about us is incomplete', () {
      final profile = barebonesProfile()..remove('description');
      expect(missingStoredProfileFields(profile), ['About us']);
      expect(isStoredProfileComplete(profile), isFalse);
    });

    test('a missing phone number is incomplete', () {
      final profile = barebonesProfile()..remove('phoneNumber');
      expect(missingStoredProfileFields(profile), ['Phone number']);
      expect(isStoredProfileComplete(profile), isFalse);
    });

    test('a missing email address is incomplete', () {
      final profile = barebonesProfile()..remove('emailAddress');
      expect(missingStoredProfileFields(profile), ['Email address']);
      expect(isStoredProfileComplete(profile), isFalse);
    });

    test('whitespace-only required values are incomplete', () {
      final profile = barebonesProfile()
        ..['companyName'] = '   '
        ..['description'] = '\n\t '
        ..['phoneNumber'] = '          '
        ..['emailAddress'] = '   ';
      expect(
        missingStoredProfileFields(profile),
        ['Company name', 'About us', 'Phone number', 'Email address'],
      );
    });

    test('a nine-digit phone number is not a phone number', () {
      final profile = barebonesProfile()..['phoneNumber'] = '987654321';
      expect(missingStoredProfileFields(profile), ['Phone number']);
    });

    test('an eleven-digit phone number is not a phone number', () {
      final profile = barebonesProfile()..['phoneNumber'] = '98765432100';
      expect(missingStoredProfileFields(profile), ['Phone number']);
    });

    test('a malformed email address is rejected', () {
      for (final bad in [
        'hello.example.com',
        'hello@',
        '@example.com',
        'hello@example',
        'hello world@example.com',
        'hello@@example.com',
      ]) {
        final profile = barebonesProfile()..['emailAddress'] = bad;
        expect(
          missingStoredProfileFields(profile),
          ['Email address'],
          reason: '"$bad" should not be a valid email address',
        );
      }
    });

    test('an ordinary business email address is accepted', () {
      for (final good in [
        'hello@example.com',
        'first.last@sub.example.co.uk',
        'contact+events@example.io',
        '  spaced@example.com  ',
      ]) {
        final profile = barebonesProfile()..['emailAddress'] = good;
        expect(
          missingStoredProfileFields(profile),
          isEmpty,
          reason: '"$good" should be a valid email address',
        );
      }
    });

    test('an email and phone alone are not enough', () {
      expect(
        isStoredProfileComplete(<String, dynamic>{
          'emailAddress': 'hello@example.com',
          'phoneNumber': '9876543210',
        }),
        isFalse,
      );
    });

    test('the optional fields never make a profile incomplete', () {
      final profile = barebonesProfile()
        ..['profileImage'] = ''
        ..['website'] = ''
        ..['links'] = <dynamic>[]
        ..['images'] = <dynamic>[];
      expect(missingStoredProfileFields(profile), isEmpty);
    });

    test('a field stored as the wrong type reads as absent, not a crash', () {
      final profile = barebonesProfile()..['companyName'] = 42;
      expect(missingStoredProfileFields(profile), ['Company name']);
    });

    test('the stored check and the editor check agree', () {
      final profile = barebonesProfile();
      expect(
        missingStoredProfileFields(profile),
        missingProfileFields(
          companyName: profile['companyName'] as String,
          description: profile['description'] as String,
          phoneNumber: profile['phoneNumber'] as String,
          emailAddress: profile['emailAddress'] as String,
        ),
      );
    });
  });

  group('submitting a generated listing', () {
    testWidgets('an incomplete profile gets the dialog and no submission',
        (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(<String, dynamic>{'companyName': 'Only this'}),
      );
      await tester.pumpAndSettle();

      expect(vendor.submitted, isEmpty);
      expect(find.text('Complete Your Profile'), findsOneWidget);
      expect(
        find.text('Please complete your profile before submitting vendor '
            'details. This helps the admin identify and contact you.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('a user who has never saved a profile gets the dialog',
        (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(null),
      );
      await tester.pumpAndSettle();

      expect(vendor.submitted, isEmpty);
      expect(find.text('Complete Your Profile'), findsOneWidget);
    });

    testWidgets('Cancel closes the dialog and still submits nothing',
        (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(null),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Complete Your Profile'), findsNothing);
      expect(find.text('templates'), findsOneWidget);
      expect(vendor.submitted, isEmpty);
    });

    testWidgets('Edit Profile opens the profile editor', (tester) async {
      await tester.pumpWidget(host());

      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: _SpyVendor(),
        userProfile: _StubProfile(<String, dynamic>{
          'companyName': 'Half Filled Co',
          'emailAddress': 'half@example.com',
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      // Opened with what is already stored, not blank.
      expect(find.text('Half Filled Co'), findsOneWidget);
      expect(find.text('half@example.com'), findsOneWidget);
    });

    testWidgets('a complete profile submits exactly as before',
        (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(completeProfile()),
      );
      await tester.pumpAndSettle();

      expect(vendor.submitted, ['v1:true']);
      expect(find.text('Complete Your Profile'), findsNothing);
    });

    testWidgets('a profile with only the four required fields submits',
        (tester) async {
      // No profile image, website, social links or portfolio: none of them
      // may stand between the user and a submission.
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(barebonesProfile()),
      );
      await tester.pumpAndSettle();

      expect(vendor.submitted, ['v1:true']);
      expect(find.text('Complete Your Profile'), findsNothing);
    });

    testWidgets('a second tap while the first is in flight is ignored',
        (tester) async {
      await tester.pumpWidget(host());

      final gate = Completer<void>();
      final vendor = _SpyVendor();
      final profile = _StubProfile(completeProfile(), gate: gate);

      final first = submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: profile,
      );
      final second = submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: profile,
      );

      expect(isSubmissionInFlight('v1'), isTrue);

      gate.complete();
      await first;
      await second;
      await tester.pumpAndSettle();

      expect(profile.reads, 1);
      expect(vendor.submitted, ['v1:true']);
      expect(isSubmissionInFlight('v1'), isFalse);
    });

    testWidgets('two different listings are not blocked by each other',
        (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      final profile = _StubProfile(completeProfile());

      await submitGeneratedVendor(
          uid: 'u1',
          documentId: 'v1',
          generatedVendor: vendor,
          userProfile: profile);
      await submitGeneratedVendor(
          uid: 'u1',
          documentId: 'v2',
          generatedVendor: vendor,
          userProfile: profile);
      await tester.pumpAndSettle();

      expect(vendor.submitted, ['v1:true', 'v2:true']);
    });

    testWidgets('tapping again after the first finishes submits again',
        (tester) async {
      // The gate must not latch: a rejected listing can be re-sent.
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      final profile = _StubProfile(completeProfile());

      await submitGeneratedVendor(
          uid: 'u1',
          documentId: 'v1',
          generatedVendor: vendor,
          userProfile: profile);
      await submitGeneratedVendor(
          uid: 'u1',
          documentId: 'v1',
          generatedVendor: vendor,
          userProfile: profile);
      await tester.pumpAndSettle();

      expect(vendor.submitted, ['v1:true', 'v1:true']);
    });

    testWidgets('a failed profile read submits nothing and does not accuse '
        'the user of an incomplete profile', (tester) async {
      await tester.pumpWidget(host());

      final vendor = _SpyVendor();
      await submitGeneratedVendor(
        uid: 'u1',
        documentId: 'v1',
        generatedVendor: vendor,
        userProfile: _StubProfile(null, failure: Exception('offline')),
      );
      await tester.pump();

      expect(vendor.submitted, isEmpty);
      expect(find.text('Complete Your Profile'), findsNothing);
      expect(isSubmissionInFlight('v1'), isFalse);
      expect(
        find.text('Could not check your profile. Please try again.'),
        findsOneWidget,
      );

      // Let GetX's own dismissal timer run out, or it outlives the tree.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}

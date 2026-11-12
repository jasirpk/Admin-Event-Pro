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

/// A profile that would pass the editor's own save check.
Map<String, dynamic> completeProfile() => <String, dynamic>{
      'companyName': 'Tathkarah Events',
      'description': 'We run weddings and corporate events.',
      'phoneNumber': '9876543210',
      'emailAddress': 'hello@example.com',
      'website': 'https://example.com',
      'profileImage': 'profile_images/abc.jpg',
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
    test('a profile with every required field is complete', () {
      expect(missingStoredProfileFields(completeProfile()), isEmpty);
      expect(isStoredProfileComplete(completeProfile()), isTrue);
    });

    test('no profile document at all is missing everything', () {
      expect(
        missingStoredProfileFields(null),
        ['Company name', 'About', 'Phone number', 'Email address', 'Website', 'Profile photo'],
      );
    });

    test('an empty document is missing everything', () {
      expect(missingStoredProfileFields(<String, dynamic>{}).length, 6);
    });

    test('a nine-digit phone number is not a phone number', () {
      final profile = completeProfile()..['phoneNumber'] = '987654321';
      expect(missingStoredProfileFields(profile), ['Phone number']);
    });

    test('an address without an @ is not an email address', () {
      final profile = completeProfile()..['emailAddress'] = 'hello.example.com';
      expect(missingStoredProfileFields(profile), ['Email address']);
    });

    test('whitespace is not a company name', () {
      final profile = completeProfile()..['companyName'] = '   ';
      expect(missingStoredProfileFields(profile), ['Company name']);
    });

    test('a profile with no photo is incomplete', () {
      final profile = completeProfile()..['profileImage'] = '';
      expect(missingStoredProfileFields(profile), ['Profile photo']);
    });

    test('an email and phone alone are not enough', () {
      // The brief's explicit warning: contact details do not make a profile.
      expect(
        isStoredProfileComplete(<String, dynamic>{
          'emailAddress': 'hello@example.com',
          'phoneNumber': '9876543210',
        }),
        isFalse,
      );
    });

    test('a field stored as the wrong type reads as absent, not a crash', () {
      final profile = completeProfile()..['companyName'] = 42;
      expect(missingStoredProfileFields(profile), ['Company name']);
    });

    test('the stored check and the editor check agree', () {
      final profile = completeProfile();
      expect(
        missingStoredProfileFields(profile),
        missingProfileFields(
          companyName: profile['companyName'] as String,
          description: profile['description'] as String,
          phoneNumber: profile['phoneNumber'] as String,
          emailAddress: profile['emailAddress'] as String,
          website: profile['website'] as String,
          hasAvatar: true,
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

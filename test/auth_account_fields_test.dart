import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which account fields a sign-in adds to `entrepreneurs/{uid}`.
///
/// [accountInitialisers] is the half of `saveAuthState` that carries the
/// rules; the other half is a Firestore transaction, which this project has no
/// way to fake without a new dev dependency. So the decision is tested here and
/// the transaction is left to a real sign-in.
///
/// A stand-in for `FieldValue.serverTimestamp()`. The production call passes
/// the sentinel itself; what matters to these tests is only *whether* the key
/// is written, and two `FieldValue`s are not comparable by value.
const Object _serverTimestamp = '<server-timestamp>';

Map<String, Object?> initialisers(Map<String, dynamic>? existing) =>
    accountInitialisers(existing, createdAt: _serverTimestamp);

void main() {
  group('accountInitialisers', () {
    test('a document that does not exist yet gets all three fields', () {
      expect(initialisers(null), {
        'isActive': true,
        'platform': 'mobile',
        'createdAt': _serverTimestamp,
      });
    });

    test('an empty document gets all three fields', () {
      // What a Google or Facebook sign-in used to leave behind once
      // saveAuthState had merged uid and email and nothing else.
      expect(initialisers(const {'uid': 'u1', 'email': 'a@b.c'}), {
        'isActive': true,
        'platform': 'mobile',
        'createdAt': _serverTimestamp,
      });
    });

    test('an absent isActive is initialised to true', () {
      expect(initialisers(const {'platform': 'mobile', 'createdAt': 1}),
          {'isActive': true});
    });

    test('an explicit isActive: false is left alone', () {
      // The whole reason for reading before writing: re-asserting true here
      // would reactivate a deliberately deactivated account on its owner's
      // next sign-in.
      final fields =
          initialisers(const {'isActive': false, 'platform': 'mobile', 'createdAt': 1});

      expect(fields.containsKey('isActive'), isFalse);
      expect(fields, isEmpty);
    });

    test('an existing isActive: true is not rewritten', () {
      final fields =
          initialisers(const {'isActive': true, 'platform': 'mobile', 'createdAt': 1});

      expect(fields.containsKey('isActive'), isFalse);
    });

    test('an absent platform is initialised to mobile', () {
      expect(initialisers(const {'isActive': true, 'createdAt': 1}),
          {'platform': 'mobile'});
    });

    test('an existing platform is preserved whatever it says', () {
      final fields = initialisers(
          const {'isActive': true, 'platform': 'web', 'createdAt': 1});

      expect(fields.containsKey('platform'), isFalse);
    });

    test('an absent createdAt is initialised from the injected value', () {
      expect(initialisers(const {'isActive': true, 'platform': 'mobile'}),
          {'createdAt': _serverTimestamp});
    });

    test('an existing createdAt is preserved', () {
      final fields = initialisers(
          const {'isActive': true, 'platform': 'mobile', 'createdAt': 1700000});

      expect(fields.containsKey('createdAt'), isFalse);
    });

    test('a null stored value still counts as present', () {
      // containsKey, not a null check: a field someone explicitly cleared is
      // still a decision, and re-initialising it would undo that.
      final fields = initialisers(
          const {'isActive': null, 'platform': null, 'createdAt': null});

      expect(fields, isEmpty);
    });

    test('no profile field is ever named in the result', () {
      // saveAuthState merges this map, so a key appearing here would overwrite
      // the stored value. Only the three account fields may ever be in it.
      const profile = {
        'companyName': 'Tathkarah',
        'description': 'about us',
        'website': 'https://example.com',
        'phoneNumber': '1234567890',
        'emailAddress': 'a@b.c',
        'profileImage': 'profile_images/u1/1-a.jpg',
        'images': [],
        'links': [],
      };

      final fields = initialisers(profile);

      for (final key in profile.keys) {
        expect(fields.containsKey(key), isFalse,
            reason: '$key must never be written by saveAuthState');
      }

      // The three account fields are all absent from `profile`, so all three
      // are still initialised — the profile keys simply do not interfere.
      expect(fields.keys.toSet(), {'isActive', 'platform', 'createdAt'});
    });

    test('a fully populated document produces no write at all', () {
      // The email/password SignUp handler writes all three before calling
      // saveAuthState, so that flow must stay byte-identical to before.
      final fields = initialisers(const {
        'uid': 'u1',
        'email': 'a@b.c',
        'platform': 'mobile',
        'isActive': true,
        'createdAt': 1700000,
      });

      expect(fields, isEmpty);
    });
  });
}

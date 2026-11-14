import 'dart:io';

import 'package:get/get_utils/get_utils.dart';

/// Reading and editing an `entrepreneurs/{uid}` profile document.

/// One portfolio row in the editor.
///
/// A row is either an image the profile already stores ([existingRef] set) or
/// one the user just picked ([picked] set). Holding both in one object is
/// what lets the editor add and remove rows without the rest shifting, and
/// what makes "I only changed my company name" leave every image alone.
class PortfolioRow {
  /// The stored reference — an R2 object key, or a legacy Firebase Storage
  /// URL on an older profile. Null for a row the user just added.
  final String? existingRef;

  /// A locally chosen image, not yet uploaded. Wins over [existingRef].
  File? picked;

  PortfolioRow({this.existingRef, this.picked});

  bool get hasImage => picked != null || existingRef != null;
}

/// The portfolio array as stored: `[{image: <key or URL>}, …]`.
///
/// Tolerates a missing field, a null, or an entry of the wrong shape — an
/// older profile may have any of those, and a malformed row should not take
/// down the whole screen.
List<String> profilePortfolioRefs(dynamic raw) {
  if (raw is! List) return const [];

  final refs = <String>[];

  for (final entry in raw) {
    if (entry is! Map) continue;
    final image = entry['image'];
    if (image is String && image.trim().isNotEmpty) refs.add(image);
  }

  return refs;
}

/// The links array as stored: `[{link: <string>}, …]`.
List<String> profileLinks(dynamic raw) {
  if (raw is! List) return const [];

  final links = <String>[];

  for (final entry in raw) {
    if (entry is! Map) continue;
    final link = entry['link'];
    if (link is String) links.add(link);
  }

  return links;
}

/// A plain string field, or '' when absent — never a failed cast.
String profileText(dynamic raw) => raw is String ? raw : '';

/// The required fields a profile is still missing, in the editor's own order.
///
/// Four fields make a profile registered: a company name, an about-us, a
/// phone number and an email address — everything the admin needs to
/// recognise a submission and get back to whoever sent it. A profile image,
/// a website, social links and the portfolio are all optional, and their
/// absence never blocks a submission.
///
/// These are the conditions the profile editor refuses to save on
/// (`ProfileScreen._save`). They live here, in one place, so that
/// "complete enough for the editor to save" and "complete enough for the
/// admin to act on" can never drift apart: a profile the editor would
/// reject must not count as registered anywhere else in the app.
///
/// An empty result means the profile is complete.
List<String> missingProfileFields({
  required String companyName,
  required String description,
  required String phoneNumber,
  required String emailAddress,
}) {
  return [
    if (companyName.trim().isEmpty) 'Company name',
    if (description.trim().isEmpty) 'About us',
    if (!isValidProfilePhoneNumber(phoneNumber)) 'Phone number',
    if (!isValidProfileEmail(emailAddress)) 'Email address',
  ];
}

/// The phone-number format this app has always used: ten characters.
///
/// Deliberately unchanged. The profile field is numeric-only
/// (`TextInputType.number`), and tightening this to digits-only here would
/// retroactively invalidate stored numbers that the editor once accepted.
bool isValidProfilePhoneNumber(String phoneNumber) =>
    phoneNumber.trim().length == 10;

/// A syntactically valid email address.
///
/// [GetUtils.isEmail] rather than a hand-rolled pattern: `get` is already a
/// direct dependency, and its regex is the ordinary one. The sign-in screen's
/// `contains('@gmail.com')` is not reused on purpose — a business contact
/// address is usually not a Gmail one.
bool isValidProfileEmail(String emailAddress) =>
    GetUtils.isEmail(emailAddress.trim());

/// The same check, against a stored `entrepreneurs/{uid}` document.
///
/// A null [data] — no profile saved yet — is missing everything, and a field
/// stored as the wrong type reads as absent rather than throwing.
List<String> missingStoredProfileFields(Map<String, dynamic>? data) {
  return missingProfileFields(
    companyName: profileText(data?['companyName']),
    description: profileText(data?['description']),
    phoneNumber: profileText(data?['phoneNumber']),
    emailAddress: profileText(data?['emailAddress']),
  );
}

/// Whether the stored profile identifies its owner well enough for the admin
/// to recognise and contact them.
///
/// `profileImage`, `website`, `links` and the portfolio are not consulted:
/// they are optional, and a profile without them still submits.
bool isStoredProfileComplete(Map<String, dynamic>? data) =>
    missingStoredProfileFields(data).isEmpty;

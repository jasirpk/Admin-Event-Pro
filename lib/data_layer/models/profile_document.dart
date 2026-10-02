import 'dart:io';

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

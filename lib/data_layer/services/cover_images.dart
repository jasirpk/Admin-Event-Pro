import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

/// A cover-image save that failed, carrying a safe reason.
///
/// [reason] is a Firebase error code such as `permission-denied`, or a
/// runtime type name — never a message, URL or token.
class CoverImageUploadException implements Exception {
  const CoverImageUploadException(this.reason);

  final String reason;

  @override
  String toString() => 'CoverImageUploadException($reason)';
}

/// Reads and writes the entrepreneur's chosen cover image.
///
/// The six covers ship inside the app, so a selection is just a note of
/// which bundled asset was picked — there is nothing to transfer. This used
/// to upload the chosen asset to Firebase Storage and store the resulting
/// download URL, which sent the app's own bundle on a round trip and
/// stopped working outright once Storage returned `quota-exceeded`.
///
/// The document keeps its shape, `{url, timestamp}`. Only the kind of string
/// in `url` changed, and every reader already branches on it:
///
///   * `assets/...`  — a bundled asset, rendered by `AssetImage`
///   * `https://...` — a legacy Storage URL, rendered by `NetworkImage`
///
/// so documents written by the old flow keep rendering untouched.
class CoverImageMethods {
  CoverImageMethods({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  // Resolved on use: touching FirebaseFirestore.instance in the initializer
  // would throw wherever no Firebase app exists.
  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  static const String _collection = 'coverImages';
  static const String _document = 'selectedImage';

  /// Whether [path] names a bundled asset rather than a remote URL.
  ///
  /// Mirrors the check in `MediaImageResolver`, which is what decides at
  /// render time whether a stored value becomes an `AssetImage`.
  static bool isBundledAssetPath(String path) =>
      path.trim().startsWith('assets/');

  /// Where [uid]'s selection lives. Owner-only by rule.
  static String selectionPath(String uid) =>
      'entrepreneurs/$uid/$_collection/$_document';

  /// Records [assetPath] as [uid]'s cover image.
  ///
  /// [uid] is the authenticated entrepreneur, passed in by the caller exactly
  /// as before; the deployed rule still refuses a write to anybody else's
  /// document, so a wrong uid fails closed rather than writing.
  ///
  /// Throws [CoverImageUploadException] with a safe reason, leaving the
  /// stored selection untouched.
  Future<void> saveSelection(String assetPath, String uid) async {
    final path = assetPath.trim();

    if (!isBundledAssetPath(path)) {
      // Guards against a future caller handing over a URL or an R2 key,
      // which would render but is not what this flow persists.
      developer.log(
        'Refusing to save a cover that is not a bundled asset',
        name: 'CoverImages',
      );

      throw const CoverImageUploadException('not-a-bundled-asset');
    }

    try {
      await _firestore
          .collection('entrepreneurs')
          .doc(uid)
          .collection(_collection)
          .doc(_document)
          .set({
        'url': path,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Only the plugin and the error code are recorded — never the message,
      // which can quote the document.
      developer.log(
        'Cover image save failed (plugin: ${e.plugin}, code: ${e.code})',
        name: 'CoverImages',
      );

      throw CoverImageUploadException(e.code);
    } catch (e) {
      developer.log(
        'Cover image save failed (type: ${e.runtimeType})',
        name: 'CoverImages',
      );

      throw CoverImageUploadException(e.runtimeType.toString());
    }
  }

  Future<DocumentSnapshot?> getCoverImage(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('entrepreneurs')
          .doc(uid)
          .collection(_collection)
          .doc(_document)
          .get();
      return documentSnapshot;
    } on FirebaseException catch (e) {
      developer.log(
        'Cover image read failed (plugin: ${e.plugin}, code: ${e.code})',
        name: 'CoverImages',
      );
      return null;
    }
  }
}

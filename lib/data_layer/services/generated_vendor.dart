import 'dart:developer';
import 'dart:io';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart'
    show ComponentRow;
import 'package:admineventpro/data_layer/services/vendor_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Prefixes of object keys that already live in Cloudflare R2.
///
/// A value carrying one of these is a *reference to media that already
/// exists* — catalogue artwork written by the Admin Console, or an image this
/// registration already uploaded — not a path on this device.
const List<String> kExistingMediaPrefixes = [
  'category_images/',
  'subcategory_images/',
  'vendor_images/',
];

/// Whether [path] already identifies stored media rather than a local file.
bool isExistingMediaReference(String path) =>
    kExistingMediaPrefixes.any((prefix) => path.startsWith(prefix));

class GeneratedVendor {
  /// Registers a vendor listing.
  ///
  /// Every image goes to Cloudflare R2 through a presigned PUT; Firebase
  /// Storage is no longer involved in this flow. Firestore stores object
  /// keys, never URLs.
  ///
  /// The listing may come from a catalogue template or stand alone:
  ///
  ///  * template — [categoryId] and [subCategoryId] are both given, and
  ///    [templateImageKey] may serve as the main image. That object already
  ///    exists in R2, so it is referenced rather than re-uploaded.
  ///  * standalone — neither id is given and [mainImageFile] is required.
  ///
  /// `uid`, `isValid`, `isAccepted`, `isRejected` and `createdAt` are absent
  /// by design: the server derives the owner from the verified ID token and
  /// sets the moderation flags itself. They cannot be passed from here
  /// because there is no parameter for them.
  ///
  /// If anything fails after the first upload, the images already stored are
  /// discarded, so an abandoned attempt does not leave objects behind.
  Future<VendorCreation> addGeneratedCategoryDetail({
    required String categoryName,
    required String description,
    required String location,
    required List<Map<String, dynamic>> images,
    required Map<String, double> budget,
    File? mainImageFile,
    String? templateImageKey,
    String? categoryId,
    String? subCategoryId,
    BuildContext? context,
  }) async {
    final api = VendorApiService.instance;

    final hasTemplate = categoryId != null && subCategoryId != null;

    final reusableTemplateKey =
        templateImageKey != null && isExistingMediaReference(templateImageKey)
            ? templateImageKey
            : null;

    // A listing needs a picture: either one the user just chose, or the
    // template's own. Checked before reserving an id so a hopeless attempt
    // never creates a namespace.
    if (mainImageFile == null &&
        !(hasTemplate && reusableTemplateKey != null)) {
      throw VendorApiException(
        'Please choose a main image for this vendor.',
      );
    }

    final vendorId = await api.createDraft();

    try {
      // An existing R2 key is referenced as-is. Only a freshly picked file is
      // uploaded, so selecting a template never copies its picture.
      final String mainImageKey = mainImageFile != null
          ? await api.uploadImage(vendorId: vendorId, file: mainImageFile)
          : reusableTemplateKey!;

      final uploaded = await uploadImages(vendorId, images);

      final creation = await api.createVendor(
        vendorId: vendorId,
        categoryName: categoryName,
        description: description,
        location: location,
        imagePathUrl: mainImageKey,
        images: uploaded,
        budget: budget,
        categoryId: hasTemplate ? categoryId : null,
        subCategoryId: hasTemplate ? subCategoryId : null,
      );

      log('Vendor details registered successfully.');
      return creation;
    } catch (e) {
      // Whatever went wrong — an upload part-way through, or the commit
      // itself — the images for this vendorId are now unreferenced. Clearing
      // them is best-effort and never masks the original failure.
      await api.discardUploads(vendorId);

      if (e is VendorApiException) rethrow;

      log('Error registering vendor details: $e');
      throw Exception('Failed to add vendor details: $e');
    }
  }

  /// Uploads each component image to R2 and pairs its object key with the
  /// caption the user typed.
  ///
  /// Each entry of [images] is `{'image': File, 'text': String}`, the shape
  /// the form already produces. The result is what Firestore stores:
  /// `{'imagePath': <R2 object key>, 'text': <caption>}`.
  Future<List<Map<String, dynamic>>> uploadImages(
    String vendorId,
    List<Map<String, dynamic>> images,
  ) async {
    final uploaded = <Map<String, dynamic>>[];

    for (final imageData in images) {
      final file = imageData['image'] as File;
      final text = (imageData['text'] as String?) ?? '';

      final objectKey = await VendorApiService.instance.uploadImage(
        vendorId: vendorId,
        file: file,
      );

      uploaded.add({'imagePath': objectKey, 'text': text});
    }

    return uploaded;
  }

  /// Builds the `images` array an edit should store.
  ///
  /// One entry per surviving row, in the order shown:
  ///
  ///  * a row the user replaced or newly filled is uploaded to R2 and stored
  ///    as `{imagePath: <object key>, text}`;
  ///  * an untouched row keeps its stored reference. A legacy URL stays under
  ///    `imageUrl` — relabelling it `imagePath` would call a Firebase Storage
  ///    URL an object key;
  ///  * a row with no image at all is dropped, since there is nothing to
  ///    store for it.
  ///
  /// Removing a row simply means it is not here. Nothing is deleted from R2:
  /// that needs an ownership-aware delete the API does not offer for a
  /// committed listing, and a component dropped by mistake stays recoverable.
  Future<List<Map<String, dynamic>>> resolveEditedRows({
    required String vendorId,
    required List<ComponentRow> rows,
  }) async {
    final resolved = <Map<String, dynamic>>[];

    for (final row in rows) {
      final text = row.caption.text;
      final picked = row.picked;

      if (picked != null) {
        final objectKey = await VendorApiService.instance.uploadImage(
          vendorId: vendorId,
          file: picked,
        );
        resolved.add({'imagePath': objectKey, 'text': text});
        continue;
      }

      final ref = row.existingRef;
      if (ref == null) continue;

      resolved.add(ref.startsWith('http')
          ? {'imageUrl': ref, 'text': text}
          : {'imagePath': ref, 'text': text});
    }

    return resolved;
  }

  Future<DocumentSnapshot?> getCategoryDetailById(String uid, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('entrepreneurs').doc(uid).collection('vendorDetails').doc(documentId).get();

      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        log('Document with ID $documentId not found.');
        return null;
      }
    } catch (e) {
      log('Error getting document by ID: $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }

  Stream<QuerySnapshot> getGeneratedCategoryDetails(String uid) {
    return FirebaseFirestore.instance.collection('entrepreneurs').doc(uid).collection('vendorDetails').snapshots();
  }

  /// Applies an edit through the API.
  ///
  /// Previously this wrote `entrepreneurs/{uid}/vendorDetails/{id}.update()`
  /// straight from the client, which meant the client decided what a listing
  /// said. The server owns that now: it verifies the listing belongs to the
  /// verified token, refuses `uid`, `createdAt`, `isValid`, `isAccepted` and
  /// `isRejected`, and confirms every new image key exists in R2.
  ///
  /// Only non-null arguments are sent, so anything omitted keeps its stored
  /// value — that is how a text-only edit leaves the images untouched.
  ///
  /// [images] must already be resolved to stored references by
  /// [resolveEditedImages]; nothing is uploaded here.
  Future<String> updateGeneratedCategoryDetail({
    required String documentId,
    String? categoryName,
    String? description,
    String? location,
    List<Map<String, dynamic>>? images,
    String? imagePathUrl,
    Map<String, double>? budget,
  }) async {
    try {
      final updatedAt = await VendorApiService.instance.updateVendor(
        vendorId: documentId,
        categoryName: categoryName,
        description: description,
        location: location,
        budget: budget,
        imagePathUrl: imagePathUrl,
        images: images,
      );

      log('Vendor details updated successfully.');
      return updatedAt;
    } on VendorApiException {
      rethrow;
    } catch (e) {
      log('Error updating vendor details: $e');
      throw Exception('Failed to update vendor details: $e');
    }
  }

  Future<void> deleteGeneratedCategoryDetail(String uid, String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('entrepreneurs').doc(uid).collection('vendorDetails').doc(documentId).delete();

      log('Vendor details deleted successfully.');
    } catch (e) {
      log('Error deleting vendor details: $e');
      throw Exception('Failed to delete vendor details: $e');
    }
  }

  Future<void> updateIsValidField(String uid, String documentId, {required bool isSumbit}) async {
    try {
      CollectionReference vendorDetailsRef = FirebaseFirestore.instance.collection('entrepreneurs').doc(uid).collection('vendorDetails');

      await vendorDetailsRef.doc(documentId).update({
        'isValid': isSumbit,
      });

      print('isValid field updated successfully.');
    } catch (e) {
      log('Error updating isValid field: $e');
      throw Exception('Failed to update isValid field: $e');
    }
  }
}

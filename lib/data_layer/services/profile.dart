import 'dart:developer';
import 'dart:io';

import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/data_layer/services/profile_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  /// Saves the profile through the API.
  ///
  /// Previously this wrote `entrepreneurs/{uid}` directly and uploaded every
  /// picture to Firebase Storage. Both moved: images go to Cloudflare R2
  /// through a presigned PUT, and the document is written server-side, which
  /// is what stops the client deciding its own `uid` or resetting
  /// `createdAt` on every save.
  ///
  /// [portfolio] is the editor's rows in display order. A row the user did
  /// not touch keeps its stored reference and is never re-uploaded; a row
  /// they picked is uploaded; a row they removed is simply absent, which is
  /// how a removal reaches Firestore.
  ///
  /// Uploads happen before the save, so a failure part-way leaves the stored
  /// profile exactly as it was.
  Future<String> saveProfile({
    required String companyName,
    required String about,
    required String phoneNumber,
    required String emailAddress,
    required String website,
    required List<PortfolioRow> portfolio,
    required List<String> links,
    String? existingProfileImage,
    File? newProfileImage,
  }) async {
    try {
      final api = ProfileApiService.instance;

      // Only a freshly picked avatar is uploaded. An unchanged one is left
      // out of the request entirely, so the stored value — R2 key or legacy
      // URL — stays exactly as it is.
      final String? profileImage = newProfileImage != null
          ? await api.uploadImage(
              kind: ProfileUploadKind.avatar,
              file: newProfileImage,
            )
          : null;

      final images = <Map<String, dynamic>>[];

      for (final row in portfolio) {
        final picked = row.picked;

        if (picked != null) {
          final objectKey = await api.uploadImage(
            kind: ProfileUploadKind.portfolio,
            file: picked,
          );
          images.add({'image': objectKey});
          continue;
        }

        final ref = row.existingRef;
        if (ref == null) continue;

        images.add({'image': ref});
      }

      final updatedAt = await api.updateProfile(
        companyName: companyName,
        description: about,
        website: website,
        phoneNumber: phoneNumber,
        emailAddress: emailAddress,
        profileImage: profileImage,
        images: images,
        links: links.map((link) => {'link': link}).toList(),
      );

      log('Profile saved successfully.');
      return updatedAt;
    } on ProfileApiException {
      rethrow;
    } catch (e) {
      log('Error saving profile: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('entrepreneurs').doc(uid);
      final documentSnapshot = await documentRef.get();
      if (!documentSnapshot.exists) {
        throw Exception('User profile does not exist for uid: $uid');
      }
      return documentSnapshot;
    } catch (e) {
      log('Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> deleteProfile(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .delete();

      log('User profile deleted successfully.');
    } catch (e) {
      log('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }
}

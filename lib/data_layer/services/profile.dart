import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfile {
  Future<void> addProfile({
    required String uid,
    required String companyName,
    required String about,
    required String imagePath,
    required String phoneNumber,
    required String emailAddress,
    required String website,
    bool validate = false,
    required List<Map<String, dynamic>> images,
    required List<Map<String, dynamic>> links,
    required double rating,
  }) async {
    try {
      String finalImagePath;
      List<Map<String, dynamic>> imageUrlList = [{}];

      if (Uri.parse(imagePath).isAbsolute) {
        finalImagePath = imagePath;
      } else {
        File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          finalImagePath = await uploadImageToFirebase(imageFile);
        } else {
          throw Exception("Image file does not exist at path: $imagePath");
        }
      }

      imageUrlList = await uploadImages(images);

      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('entrepreneurs').doc(uid);

      await documentRef.update({
        'companyName': companyName,
        'description': about,
        'website': website,
        'phoneNumber': phoneNumber,
        'emailAddress': emailAddress,
        'profileImage': finalImagePath,
        'images': imageUrlList,
        'links': links,
        'isValid': validate,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': rating,
      });

      print('Vendor details added successfully to sub-collection.');
    } catch (e) {
      print('Error adding user Profile to sub-collection: $e');
      throw Exception('Failed to add user Profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> uploadImages(
      List<Map<String, dynamic>> images) async {
    List<Map<String, dynamic>> uploadedImages = [];
    for (var image in images) {
      if (image['image'] != null) {
        try {
          String imageUrl = await uploadImageToFirebase(File(image['image']));
          uploadedImages.add({'image': imageUrl});
        } catch (e) {
          log('Failed to upload one of the images: $e');
          throw Exception('Failed to upload images: $e');
        }
      }
    }
    return uploadedImages;
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('entrepreneurs').doc(uid);
      DocumentSnapshot documentSnapshot = await documentRef.get();
      if (!documentSnapshot.exists) {
        throw Exception('User profile does not exist for uid: $uid');
      }
      return documentSnapshot;
    } catch (e) {
      log('Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<String> uploadImageToFirebase(File image) async {
    try {
      String fileName =
          'profile_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteProfile(String uid) async {
    try {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('entrepreneurs').doc(uid);

      await documentRef.delete();

      log('User profile deleted successfully.');
    } catch (e) {
      log('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }
}

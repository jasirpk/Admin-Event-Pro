import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class CoverImageMethods {
  Future<void> uploadImage(String assetPath, String uid) async {
    try {
      // Load asset image as byte data
      ByteData byteData = await rootBundle.load(assetPath);
      Uint8List imageData = byteData.buffer.asUint8List();

      String fileName = assetPath.split('/').last;
      Reference storageRef =
          FirebaseStorage.instance.ref().child('cover_images/$fileName');
      UploadTask uploadTask = storageRef.putData(imageData);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .collection('coverImages')
          .doc('selectedImage')
          .set({
        'url': downloadURL,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to upload image');
    }
  }

  Future<DocumentSnapshot?> getCoverImage(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .collection('coverImages')
          .doc('selectedImage')
          .get();
      return documentSnapshot;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }
}

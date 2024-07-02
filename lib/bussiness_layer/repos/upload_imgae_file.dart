import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadFile(File file) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('generatedVendors/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  } catch (e) {
    print(e);
    return null;
  }
}

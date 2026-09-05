import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maid_rent/config/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage
        .ref()
        .child(AppConstants.profileImagesPath)
        .child('$uid.jpg');

    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteProfileImage(String uid) async {
    try {
      await _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$uid.jpg')
          .delete();
    } catch (_) {
      // File may not exist, ignore
    }
  }
}

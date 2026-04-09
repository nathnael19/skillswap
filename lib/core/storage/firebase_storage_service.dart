import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skillswap/core/storage/storage_service.dart';

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _firebaseStorage;

  FirebaseStorageService(this._firebaseStorage);

  @override
  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}

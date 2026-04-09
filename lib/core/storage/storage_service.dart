import 'dart:io';

abstract interface class StorageService {
  /// Uploads a file to the given path in storage and returns the download URL.
  Future<String> uploadFile({
    required String path,
    required File file,
  });
}

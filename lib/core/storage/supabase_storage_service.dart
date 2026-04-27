import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillswap/core/storage/storage_service.dart';

class SupabaseStorageService implements StorageService {
  final SupabaseClient _supabaseClient;

  SupabaseStorageService(this._supabaseClient);

  @override
  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      // Create a unique filename if needed, or use the provided path
      // Assuming 'path' is the filename or a relative path within the bucket
      final response = await _supabaseClient.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      if (response.isEmpty) {
        throw Exception('Upload failed: Empty response');
      }

      final String publicUrl =
          _supabaseClient.storage.from('avatars').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Supabase upload error: $e');
    }
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String placesFolder = 'places';

  /// Upload image to Firebase Storage
  Future<String> uploadImage({
    required String userId,
    required String placeId,
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child(placesFolder).child(userId).child(fileName);

      final uploadTask = ref.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        onProgress?.call(progress);
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }

  /// Get download URL for an image
  Future<String> getImageUrl(String imagePath) async {
    try {
      final ref = _storage.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get image URL: $e';
    }
  }
}

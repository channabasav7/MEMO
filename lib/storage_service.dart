import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String placesFolder = 'places';

  /// Upload image to Firebase Storage
  Future<String> uploadImage({
    required String userId,
    required String placeId,
    File? imageFile,
    Uint8List? imageBytes,
    Function(double)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String fileName;
      Reference ref;

      if (imageFile != null) {
        fileName = '${timestamp}_${imageFile.path.split('/').last}';
        ref = _storage.ref().child(placesFolder).child(userId).child(fileName);
      final uploadTask = ref.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        onProgress?.call(progress);
      });

      await uploadTask;
      } else if (imageBytes != null) {
        fileName = '${timestamp}_upload.jpg';
        ref = _storage.ref().child(placesFolder).child(userId).child(fileName);
        final uploadTask = ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes);
          onProgress?.call(progress);
        });

        await uploadTask;
      } else {
        throw 'No image provided';
      }

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

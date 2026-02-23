import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class ImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Save image to local app directory
  /// Returns the local file path
  Future<String> saveImageLocally(File imageFile, String expenseId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageId = _uuid.v4();
    final fileName = '${expenseId}_$imageId.jpg';
    final localPath = '${appDir.path}/receipts/$fileName';
    
    // Create receipts directory if it doesn't exist
    final receiptsDir = Directory('${appDir.path}/receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    
    // Copy image to local storage
    await imageFile.copy(localPath);
    return localPath;
  }

  /// Generate thumbnail (200x200) for fast loading
  /// Returns the thumbnail file path
  Future<String> generateThumbnail(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    
    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');
    
    // Resize to 200x200 thumbnail
    final thumbnail = img.copyResize(image, width: 200, height: 200);
    
    // Save thumbnail
    final thumbnailPath = imagePath.replaceAll('.jpg', '_thumb.jpg');
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));
    
    return thumbnailPath;
  }

  /// Upload image to Firebase Storage
  /// Returns the cloud URL
  Future<String?> uploadToFirebaseStorage(
    String localPath,
    String userId,
    String expenseId,
    String imageId,
  ) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      
      // Upload to: users/{userId}/receipts/{expenseId}/{imageId}.jpg
      final ref = _storage.ref().child('users/$userId/receipts/$expenseId/$imageId.jpg');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'expenseId': expenseId, 'imageId': imageId},
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  /// Delete image from local storage and cloud
  Future<void> deleteImage(String imageId, String userId, String expenseId, {String? localPath}) async {
    // Delete local file
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        
        // Delete thumbnail
        final thumbnailPath = localPath.replaceAll('.jpg', '_thumb.jpg');
        final thumbFile = File(thumbnailPath);
        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }
    }
    
    // Delete from Firebase Storage
    try {
      final ref = _storage.ref().child('users/$userId/receipts/$expenseId/$imageId.jpg');
      await ref.delete();
    } catch (e) {
      print('Cloud delete failed: $e');
    }
  }

  /// Get local file size in MB
  Future<double> getFileSizeMB(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}

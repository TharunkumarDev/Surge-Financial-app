import 'dart:io';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/isar_provider.dart';
import '../domain/bill_image_model.dart';

part 'bill_image_repository.g.dart';

/// Repository for querying and managing bill images
class BillImageRepository {
  final Isar isar;

  BillImageRepository({required this.isar});

  /// Get all bill images
  Future<List<BillImage>> getAllBillImages() async {
    return await isar.billImages
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get bill images for specific expense IDs
  Future<List<BillImage>> getBillImagesByExpenseIds(List<int> expenseIds) async {
    if (expenseIds.isEmpty) return [];
    
    final images = <BillImage>[];
    for (final expenseId in expenseIds) {
      final expenseImages = await isar.billImages
          .where()
          .expenseIdEqualTo(expenseId)
          .findAll();
      images.addAll(expenseImages);
    }
    return images;
  }

  /// Search bill images by OCR text content
  Future<List<BillImage>> searchBillsByOcrText(String query) async {
    if (query.isEmpty) return [];
    
    final allImages = await isar.billImages.where().findAll();
    
    // Filter images that have OCR text containing the query (case-insensitive)
    return allImages.where((image) {
      if (image.ocrText == null || image.ocrText!.isEmpty) return false;
      return image.ocrText!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get bill image by image ID
  Future<BillImage?> getBillImageByImageId(String imageId) async {
    return await isar.billImages
        .where()
        .filter()
        .imageIdEqualTo(imageId)
        .findFirst();
  }

  /// Get bill images that are successfully uploaded
  Future<List<BillImage>> getUploadedBillImages() async {
    return await isar.billImages
        .where()
        .filter()
        .isUploadedEqualTo(true)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Delete a bill image by ID
  Future<void> deleteBillImage(int id) async {
    final image = await isar.billImages.get(id);
    if (image != null) {
      // Delete local file if it exists
      if (image.localPath != null) {
        final file = File(image.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Delete thumbnail if it exists
      if (image.thumbnailPath != null) {
        final file = File(image.thumbnailPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await isar.writeTxn(() async {
        await isar.billImages.delete(id);
      });
    }
  }

  /// Delete all bill images for a specific expense ID
  Future<void> deleteBillImagesByExpenseId(int expenseId) async {
    final images = await isar.billImages
        .where()
        .expenseIdEqualTo(expenseId)
        .findAll();
        
    if (images.isEmpty) return;

    await isar.writeTxn(() async {
      for (final image in images) {
        // Delete local files
        if (image.localPath != null) {
          final file = File(image.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        if (image.thumbnailPath != null) {
          final file = File(image.thumbnailPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        // Delete from Isar
        await isar.billImages.delete(image.id);
      }
    });
  }
}

@riverpod
Future<BillImageRepository> billImageRepository(BillImageRepositoryRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return BillImageRepository(isar: isar);
}

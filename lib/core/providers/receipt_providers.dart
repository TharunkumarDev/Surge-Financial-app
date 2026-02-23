import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/isar_provider.dart';
import '../../../core/services/image_storage_service.dart';
import '../../../core/services/receipt_index_service.dart';

// Image Storage Service Provider
final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});

// Receipt Index Service Provider
final receiptIndexServiceProvider = Provider<ReceiptIndexService>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return ReceiptIndexService(isar);
});

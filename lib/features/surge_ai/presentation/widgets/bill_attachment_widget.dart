import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/design_system.dart';
import '../../../expense/domain/expense_model.dart';
import '../../../expense/domain/bill_image_model.dart';
import '../../../expense/data/bill_image_repository.dart';
import '../../../../core/providers/currency_provider.dart';

/// Widget to display bill attachments in chat messages
class BillAttachmentWidget extends ConsumerWidget {
  final List<int> expenseIds;

  const BillAttachmentWidget({
    super.key,
    required this.expenseIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billImageRepoAsync = ref.watch(billImageRepositoryProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return billImageRepoAsync.when(
      data: (billImageRepo) {
        return FutureBuilder<List<BillImage>>(
          future: billImageRepo.getBillImagesByExpenseIds(expenseIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final billImages = snapshot.data!;

            return Container(
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bill images horizontal scroll
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: billImages.length,
                      itemBuilder: (context, index) {
                        final billImage = billImages[index];
                        return _BillImageCard(
                          billImage: billImage,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _BillImageCard extends StatelessWidget {
  final BillImage billImage;
  final bool isDark;

  const _BillImageCard({
    required this.billImage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Bill image
            if (billImage.localPath != null)
              Image.file(
                File(billImage.localPath!),
                width: 150,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            else if (billImage.cloudUrl != null)
              Image.network(
                billImage.cloudUrl!,
                width: 150,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            else
              _buildPlaceholder(),

            // Tap to view full image
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFullImage(context),
                  child: Container(),
                ),
              ),
            ),

            // Upload status indicator
            if (!billImage.isUploaded && billImage.uploadFailed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.destructive,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 150,
      height: 200,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.receipt_long,
        size: 48,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    if (billImage.localPath == null && billImage.cloudUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: billImage.localPath != null
                    ? Image.file(File(billImage.localPath!))
                    : Image.network(billImage.cloudUrl!),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

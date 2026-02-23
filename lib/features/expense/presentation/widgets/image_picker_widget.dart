import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/design_system.dart';
import '../../../subscription/providers/subscription_providers.dart';
import '../../../subscription/domain/subscription_plan.dart';
import '../../../subscription/presentation/widgets/upgrade_dialog.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  final List<File> selectedImages;
  final Function(File) onImageAdded;
  final Function(int) onImageRemoved;
  
  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImageAdded,
    required this.onImageRemoved,
  });

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final tier = ref.read(currentSubscriptionTierProvider);
    final entitlement = ref.read(entitlementServiceProvider);
    
    // Check if user can attach more images
    if (!entitlement.canAttachMoreImages(tier, widget.selectedImages.length)) {
      final maxImages = entitlement.getMaxBillImagesPerExpense(tier);
      final minimumTier = tier == SubscriptionTier.free ? SubscriptionTier.basic : SubscriptionTier.pro;
      
      showDialog(
        context: context,
        builder: (context) => UpgradeDialog(
          featureName: tier == SubscriptionTier.free 
              ? 'Receipt Images (Upgrade to Basic for 1 image)'
              : 'Multiple Receipt Images (${maxImages} image limit)',
          minimumTier: minimumTier,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      
      if (image != null) {
        widget.onImageAdded(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = ref.watch(currentSubscriptionTierProvider);
    final entitlement = ref.watch(entitlementServiceProvider);
    final canAttachMore = entitlement.canAttachMoreImages(tier, widget.selectedImages.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Receipt Images',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.selectedImages.isNotEmpty)
              Text(
                '${widget.selectedImages.length}${tier == SubscriptionTier.pro ? '' : '/${entitlement.getMaxBillImagesPerExpense(tier)}'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.greyText,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Image thumbnails
        if (widget.selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedImages.length + (canAttachMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.selectedImages.length) {
                  return _buildAddButton();
                }
                return _buildImageThumbnail(widget.selectedImages[index], index);
              },
            ),
          )
        else
          _buildAddButton(),
      ],
    );
  }

  Widget _buildImageThumbnail(File image, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onImageRemoved(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : AppTheme.darkGreen.withOpacity(0.2),
            width: 1,
            style: BorderStyle.none, // Solid border looks better than dashed usually, but let's use dashed if preferred or just solid subtle
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.darkGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                color: isDark ? Colors.white70 : AppTheme.darkGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Image',
              style: TextStyle(
                color: isDark ? Colors.white60 : AppTheme.darkGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.darkGreen),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.darkGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

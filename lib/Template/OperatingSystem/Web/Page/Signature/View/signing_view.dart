import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import '../Widget/signing_header.dart';
import '../Widget/pdf_document_viewer.dart';
import '../Widget/signing_sidebar.dart';
import '../Widget/guidance_button.dart';
import '../Widget/sidebar_popovers.dart';

class SigningView extends GetView<SigningController> {
  const SigningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SigningHeader(controller: controller),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDocumentArea(context)),
                    if (context.width > 900)
                      SigningSidebar(controller: controller),
                  ],
                ),
                if (context.width > 900) _buildPopoverOverlay(),
              ],
            ),
          ),
          if (context.width <= 900) MobileBottomBar(controller: controller),
        ],
      ),
    );
  }

  Widget _buildDocumentArea(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton();
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState();
        }

        return Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: context.width <= 900 ? double.infinity : 850,
                ),
                width: double.infinity,
                color: AppColors.backgroundLight,
                child: PdfDocumentViewer(controller: controller),
              ),
            ),
            // Floating Guidance Button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(child: GuidanceButton(controller: controller)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPopoverOverlay() {
    return Obx(() {
      if (controller.activePopover.value.isEmpty) {
        return const SizedBox.shrink();
      }

      Widget popover;
      switch (controller.activePopover.value) {
        case 'search':
          popover = SearchPopover(
            onClose: () => controller.activePopover.value = '',
          );
          break;
        case 'thumbnails':
          popover = ThumbnailsPopover(
            onClose: () => controller.activePopover.value = '',
          );
          break;
        case 'download':
          popover = DownloadPopover(
            onClose: () => controller.activePopover.value = '',
          );
          break;
        default:
          popover = const SizedBox.shrink();
      }

      return Positioned(
        top: 0,
        bottom: 0,
        right: 80, // Approximate sidebar width in points (80.w)
        child: popover,
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to load document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.error.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.onInit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.offAllNamed('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Verifying secure token & fetching document...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

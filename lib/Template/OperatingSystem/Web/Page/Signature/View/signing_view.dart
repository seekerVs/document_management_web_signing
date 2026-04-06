import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/style.dart';
import '../Controller/signing_controller.dart';
import '../Widget/signing_header.dart';
import '../Widget/pdf_document_viewer.dart';
import '../Widget/signing_sidebar.dart';
import '../Widget/sidebar_popovers.dart';
import '../Widget/signing_footer.dart';
import '../Widget/guidance_button.dart';

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
          const SigningFooter(),
        ],
      ),
    );
  }

  Widget _buildDocumentArea(BuildContext context) {
    return Container(
      key: controller.documentAreaKey,
      color: AppColors.backgroundLight,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(context);
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(context);
        }

        // Read reactive values so Obx rebuilds on change
        final double tabTop = controller.guidanceTabTop.value;
        final double tabLeft = controller.guidanceTabLeft.value;

        return Stack(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.backgroundLight,
              child: PdfDocumentViewer(controller: controller),
            ),
            // Floating Navigation Tab with animated vertical/horizontal alignment
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              left: tabLeft,
              top: tabTop,
              child: NavigationTab(controller: controller),
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

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: AppStyle.card(radius: 8).copyWith(
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Obx(() {
          final isExpired = controller.isLinkExpired.value;
          final title = isExpired ? 'Link Expired' : 'Unable to load document';
          final message = isExpired
              ? 'The signing link you clicked is no longer valid for security reasons. Please request a new link.'
              : controller.error.value;
          final icon = isExpired ? Icons.timer_off_outlined : Icons.error_outline;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.error,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              isExpired
                  ? ElevatedButton(
                      onPressed: () => controller.resendLink(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Send New Link'),
                    )
                  : ElevatedButton(
                      onPressed: () => controller.onInit(),
                      style: ElevatedButton.styleFrom(
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
          );
        }),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Verifying secure token & fetching document...',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

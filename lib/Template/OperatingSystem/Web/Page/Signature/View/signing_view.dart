import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import '../Widget/signature_field_guest_overlay.dart';
import '../Widget/sidebar_popovers.dart';

class SigningView extends GetView<SigningController> {
  const SigningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDocumentArea(context)),
                    if (context.width > 900) _buildDesktopSidebar(context),
                  ],
                ),
                if (context.width > 900) _buildPopoverOverlay(),
              ],
            ),
          ),
          if (context.width <= 900) _buildMobileBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isMobile = context.width <= 900;
    return Container(
      height: isMobile ? 56.h : 64.h,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.w : 24.w),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Review and complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16.sp : 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _buildHeaderActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: controller.finishSigning,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Center(
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.white.withOpacity(0.5)),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                offset: const Offset(0, 40),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Other Actions',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'finish_later',
                    child: Text('Finish Later'),
                  ),
                  const PopupMenuItem(
                    value: 'decline',
                    child: Text('Decline to Sign'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white, size: 24.sp),
          offset: const Offset(0, 40),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'help', child: Text('Help & Support')),
            const PopupMenuItem(value: 'about', child: Text('About')),
          ],
        ),
      ],
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
                  maxWidth: context.width <= 900 ? double.infinity : 800,
                ),
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  vertical: context.width <= 900 ? 10.h : 40.h,
                  horizontal: context.width <= 900 ? 5.w : 20.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double scale = constraints.maxWidth / 800.0;
                    return Stack(
                      children: [
                        PdfViewPinch(
                          controller: controller.pdfController,
                          builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                            options: const DefaultBuilderOptions(),
                            documentLoaderBuilder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            pageLoaderBuilder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        ...controller.fields.map(
                          (field) => SignatureFieldGuestOverlay(
                            field: field,
                            scale: scale,
                            onTap: () => controller.onFieldTap(field),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Left Next Ribbon
            Positioned(left: 0, top: 100.h, child: _buildNextRibbon()),
            // Bottom Action
            if (controller.fields.every((f) => f.value != null))
              Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.finishSigning,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 16.h,
                      ),
                      backgroundColor: AppColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.scrollToNextField,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 16.h,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 80.w,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: const Border(left: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          const _SidebarTool(icon: Icons.auto_awesome, label: 'Summarize'),
          _SidebarTool(
            icon: Icons.search,
            label: 'Search',
            onTap: () => controller.togglePopover('search'),
          ),
          _SidebarTool(
            icon: Icons.article_outlined,
            label: 'View Pages',
            onTap: () => controller.togglePopover('thumbnails'),
          ),
          _SidebarTool(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () => controller.togglePopover('download'),
          ),
          const _SidebarTool(icon: Icons.print_outlined, label: 'Print'),
          const Spacer(),
          const _SidebarTool(icon: Icons.zoom_in, label: ''),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const _SidebarTool(icon: Icons.zoom_out, label: ''),
          SizedBox(height: 20.h),
        ],
      ),
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
        right: 80.w, // Match sidebar width
        child: popover,
      );
    });
  }

  Widget _buildNextRibbon() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(4.r),
          bottomRight: Radius.circular(4.r),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        'Next',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        constraints: BoxConstraints(maxWidth: 400.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Unable to load document',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => controller.onInit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: const Text('Retry'),
            ),
            SizedBox(height: 12.h),
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
          SizedBox(height: 24.h),
          Text(
            'Verifying secure token & fetching document...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MobileTool(
            icon: Icons.search,
            label: 'Search',
            onTap: () => _showMobileSearch(context),
          ),
          _MobileTool(
            icon: Icons.file_copy_outlined,
            label: 'Pages',
            onTap: () => _showMobileThumbnails(context),
          ),
          _MobileTool(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () => _showMobileDownload(context),
          ),
          _MobileTool(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: () => _showMobileMoreActions(context),
          ),
        ],
      ),
    );
  }

  void _showMobileSearch(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: SearchPopover(onClose: () => Get.back()),
      ),
      isScrollControlled: true,
    );
  }

  void _showMobileThumbnails(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 500.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: ThumbnailsPopover(onClose: () => Get.back()),
      ),
      isScrollControlled: true,
    );
  }

  void _showMobileDownload(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: DownloadPopover(onClose: () => Get.back()),
      ),
    );
  }

  void _showMobileMoreActions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Help & Support'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('About Scrivener'),
              onTap: () => Get.back(),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _SidebarTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SidebarTool({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.navy, size: 24.sp),
            if (label.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: AppColors.navy),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MobileTool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

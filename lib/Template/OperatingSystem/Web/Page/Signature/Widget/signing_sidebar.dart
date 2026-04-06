import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import 'sidebar_popovers.dart';

class SigningSidebar extends StatelessWidget {
  final SigningController controller;

  const SigningSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(left: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
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
          _SidebarTool(
            icon: Icons.print_outlined,
            label: 'Print',
            onTap: () {}, // Implementation placeholder
          ),
          const Spacer(),
          _SidebarTool(
            icon: Icons.zoom_in,
            label: '',
            onTap: controller.zoomIn,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Obx(
              () => Text(
                '${(controller.zoomLevel.value * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          _SidebarTool(
            icon: Icons.zoom_out,
            label: '',
            onTap: controller.zoomOut,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class MobileBottomBar extends StatelessWidget {
  final SigningController controller;

  const MobileBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // Fixed height for mobile bottom bar
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
            onTap: () => _showMobileSearch(),
          ),
          _MobileTool(
            icon: Icons.file_copy_outlined,
            label: 'Pages',
            onTap: () => _showMobileThumbnails(),
          ),
          _MobileTool(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () => _showMobileDownload(),
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

  void _showMobileSearch() {
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

  void _showMobileThumbnails() {
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

  void _showMobileDownload() {
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
              title: Text(
                'Help & Support',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(
                'About Scrivener',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
            Icon(icon, color: AppColors.primary, size: 24),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

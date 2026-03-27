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
      height: isMobile ? 56 : 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: Colors.white, size: isMobile ? 20 : 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review and complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(() => Text(
                  '${controller.fields.where((f) => f.value != null).length} of ${controller.fields.length} fields completed',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          _buildHeaderActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final bool allDone = controller.fields.isNotEmpty && controller.fields.every((f) => f.value != null);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => ElevatedButton(
          onPressed: allDone ? controller.finishSigning : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
            disabledBackgroundColor: Colors.white24,
            disabledForegroundColor: Colors.white38,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(
            'FINISH',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
          ),
        )),
        SizedBox(width: 8),
        IconButton(
          onPressed: () {}, 
          icon: Icon(Icons.more_vert, color: Colors.white),
          tooltip: 'Other Actions',
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
                  maxWidth: context.width <= 900 ? double.infinity : 850,
                ),
                width: double.infinity,
                color: AppColors.backgroundLight,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(
                      vertical: context.isMobile ? 10 : 40,
                      horizontal: context.isMobile ? 10 : 20,
                    ),
                    itemCount: controller.pdfDocument?.pagesCount ?? 0,
                    itemBuilder: (context, index) {
                      return _PdfPageWebWidget(
                        pageIndex: index + 1,
                        controller: controller,
                      );
                    },
                  ),
                ),
              ),
            ),
            // Floating Guidance Button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _buildGuidanceButton(),
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

  Widget _buildGuidanceButton() {
    final bool allDone = controller.fields.isNotEmpty && controller.fields.every((f) => f.value != null);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: allDone ? controller.finishSigning : controller.scrollToNextField,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 8,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              allDone ? 'FINISH' : 'START', // Simplified guidance
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(allDone ? Icons.check_circle : Icons.arrow_downward, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PdfPageWebWidget extends StatefulWidget {
  final int pageIndex;
  final SigningController controller;

  const _PdfPageWebWidget({
    required this.pageIndex,
    required this.controller,
  });

  @override
  State<_PdfPageWebWidget> createState() => _PdfPageWebWidgetState();
}

class _PdfPageWebWidgetState extends State<_PdfPageWebWidget> {
  Uint8List? _imageBytes;
  Size? _pageSize;

  @override
  void initState() {
    super.initState();
    _renderPage();
  }

  Future<void> _renderPage() async {
    if (widget.controller.pdfDocument == null) return;
    
    final page = await widget.controller.pdfDocument!.getPage(widget.pageIndex);
    // Render at a high resolution for web clarity
    final pageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageFormat.jpg,
      quality: 100,
    );
    
    if (mounted) {
      setState(() {
        _imageBytes = pageImage?.bytes;
        _pageSize = Size(page.width, page.height);
      });
    }
    await page.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return Container(
        height: 800,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: Colors.white),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double displayW = constraints.maxWidth;
        final double displayH = displayW * (_pageSize!.height / _pageSize!.width);
        final double scale = displayW / _pageSize!.width;

        return Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: displayW,
            height: displayH,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Obx(() {
              final pageFields = widget.controller.fields
                  .where((f) => f.page == widget.pageIndex)
                  .toList();

              return Stack(
                children: [
                  Positioned.fill(child: Image.memory(_imageBytes!, fit: BoxFit.fill)),
                  ...pageFields.map(
                    (field) => SignatureFieldGuestOverlay(
                      field: field,
                      scale: scale,
                      onTap: () => widget.controller.onFieldTap(field),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _SidebarTool extends StatelessWidget {
...
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

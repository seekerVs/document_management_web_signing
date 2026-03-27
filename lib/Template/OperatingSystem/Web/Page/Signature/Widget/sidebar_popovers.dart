import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';

class ThumbnailsPopover extends StatelessWidget {
  final VoidCallback onClose;
  const ThumbnailsPopover({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SigningController>();
    return _PopoverContainer(
      title: 'Thumbnails',
      onClose: onClose,
      child: FutureBuilder<PdfDocument>(
        future: controller.pdfController.document,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final doc = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.7,
            ),
            itemCount: doc.pagesCount,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  controller.jumpToPage(index + 1);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: PdfThumbnail(
                          pageIndex: index,
                          document: doc,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text('${index + 1}', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PdfThumbnail extends StatelessWidget {
  final int pageIndex;
  final PdfDocument document;

  const PdfThumbnail({super.key, required this.pageIndex, required this.document});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfPageImage?>(
      future: _renderPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(snapshot.data!.bytes);
        }
        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
      },
    );
  }

  Future<PdfPageImage?> _renderPage() async {
    final page = await document.getPage(pageIndex + 1);
    final pageImage = await page.render(width: page.width / 4, height: page.height / 4);
    await page.close();
    return pageImage;
  }
}

class DownloadPopover extends StatelessWidget {
  final VoidCallback onClose;
  const DownloadPopover({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SigningController>();
    return _PopoverContainer(
      title: 'Download',
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOption('Combined PDF', controller),
          _buildOption('Separate PDFs', controller),
        ],
      ),
    );
  }

  Widget _buildOption(String label, SigningController controller) {
    return InkWell(
      onTap: () {
        onClose();
        controller.downloadDocument();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(Icons.file_download_outlined, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text(label, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}

class SearchPopover extends StatelessWidget {
  final VoidCallback onClose;
  const SearchPopover({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SigningController>();
    return _PopoverContainer(
      title: 'Find',
      onClose: onClose,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (val) => controller.searchText(val),
              decoration: InputDecoration(
                hintText: 'Find in Document',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.searchResults.isEmpty && controller.searchQuery.isNotEmpty) {
                return Center(
                  child: Text('No results for "${controller.searchQuery.value}"',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
                );
              }
              return ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final pageNum = controller.searchResults[index];
                  return ListTile(
                    leading: Icon(Icons.description, size: 20.sp, color: AppColors.primary),
                    title: Text('Result on Page $pageNum', style: TextStyle(fontSize: 14.sp)),
                    onTap: () {
                      controller.jumpToPage(pageNum);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PopoverContainer extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const _PopoverContainer({
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(-2, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 18.sp, color: AppColors.navy)),
                InkWell(onTap: onClose, child: Icon(Icons.close, size: 24.sp, color: AppColors.navy)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

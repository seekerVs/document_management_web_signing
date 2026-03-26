import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import '../Widget/signature_field_guest_overlay.dart';

class SigningView extends GetView<SigningController> {
  const SigningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildDocumentArea(context)),
                if (context.width > 900) _buildDesktopSidebar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Review and complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: controller.finishSigning,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Finish'),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentArea(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Center(
              child: Container(
                width: 800,
                margin: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
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
                child: Stack(
                  children: [
                    PdfViewPinch(
                      controller: controller.pdfController,
                      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        pageLoaderBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    ...controller.fields.map(
                      (field) => SignatureFieldGuestOverlay(
                        field: field,
                        onTap: () => controller.onFieldTap(field),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: controller.scrollToNextField,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
      width: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _SidebarTool(icon: Icons.search, label: 'Search'),
          _SidebarTool(icon: Icons.file_copy_outlined, label: 'Pages'),
          _SidebarTool(icon: Icons.download_outlined, label: 'Download'),
          _SidebarTool(icon: Icons.print_outlined, label: 'Print'),
          const Spacer(),
          _SidebarTool(icon: Icons.zoom_in, label: '100%'),
          _SidebarTool(icon: Icons.zoom_out, label: 'Zoom Out'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarTool extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SidebarTool({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

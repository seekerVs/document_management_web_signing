import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';
import '../Controller/signing_controller.dart';
import 'signature_field_guest_overlay.dart';
import '../../../../../Utils/Constant/colors.dart';

class PdfDocumentViewer extends StatelessWidget {
  final SigningController controller;

  const PdfDocumentViewer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = context.width > 900;
    return GestureDetector(
      onTap: () => controller.activeFieldActionFieldId.value = null,
      child: InteractiveViewer(
        transformationController: controller.transformationController,
        onInteractionUpdate: controller.onInteractionUpdate,
        minScale: 1.0,
        maxScale: 3.0,
        scaleEnabled: !isDesktop,
        child: ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(
            vertical: context.width <= 900 ? 10 : 40,
            horizontal: context.width <= 900
                ? 50
                : 80, // Added padding for the left gutter indicator
          ),
          itemCount: (controller.pdfDocument?.pagesCount ?? 0) + 1,
          itemBuilder: (context, index) {
            if (controller.pdfDocument != null &&
                index == controller.pdfDocument!.pagesCount) {
              return _buildBottomFinishButton(context);
            }
            return _PdfPageWebWidget(
              pageIndex: index + 1,
              controller: controller,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomFinishButton(BuildContext context) {
    return Obx(() {
      final bool allDone =
          controller.fields.isNotEmpty &&
          controller.fields.every((f) => f.value != null);
      if (!allDone) return const SizedBox(height: 100);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.topCenter,
        child: ElevatedButton(
          key: controller.bottomFinishButtonKey,
          onPressed: controller.finishSigning,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Finish',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }
}

class _PdfPageWebWidget extends StatefulWidget {
  final int pageIndex;
  final SigningController controller;

  const _PdfPageWebWidget({required this.pageIndex, required this.controller});

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
    final pageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
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
        decoration: const BoxDecoration(color: Colors.white),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxAllowedWidth = context.width <= 900
            ? double.infinity
            : 850.0;
        final double displayW = constraints.maxWidth > maxAllowedWidth
            ? maxAllowedWidth
            : constraints.maxWidth;
        final double displayH =
            displayW * (_pageSize!.height / _pageSize!.width);

        return Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: displayW,
            height: displayH,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              final pageFields = widget.controller.fields
                  .where((f) => f.page == widget.pageIndex - 1)
                  .toList();

              return Stack(
                clipBehavior:
                    Clip.none, // Allow indicator to float in the gutter
                children: [
                  Positioned.fill(
                    child: Image.memory(_imageBytes!, fit: BoxFit.fill),
                  ),
                  ...pageFields.map(
                    (field) => SignatureFieldGuestOverlay(
                      field: field,
                      pageWidth: displayW,
                      pageHeight: displayH,
                      fieldKey: widget.controller.fieldKeys[field.fieldId],
                      isActive:
                          widget.controller.activeFieldId.value ==
                          field.fieldId,
                      hasStarted: widget.controller.hasStarted.value,
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

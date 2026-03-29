import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import 'signature_field_guest_overlay.dart';

class PdfDocumentViewer extends StatelessWidget {
  final SigningController controller;

  const PdfDocumentViewer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: controller.transformationController,
      onInteractionUpdate: controller.onInteractionUpdate,
      minScale: 1.0,
      maxScale: 3.0,
      child: ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          vertical: context.width <= 900 ? 10 : 40,
          horizontal: context.width <= 900 ? 10 : 20,
        ),
        itemCount: controller.pdfDocument?.pagesCount ?? 0,
        itemBuilder: (context, index) {
          return _PdfPageWebWidget(
            pageIndex: index + 1,
            controller: controller,
          );
        },
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
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
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

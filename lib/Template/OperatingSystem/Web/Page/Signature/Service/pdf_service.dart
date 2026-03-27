import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as px;
import '../Model/signature_field_model.dart';

class PdfService {
  /// Merges signature/text/date fields into the original PDF bytes
  /// by rendering each page as a high-res image and overlaying fields.
  Future<Uint8List> mergeSignatures({
    required px.PdfDocument document,
    required List<SignatureFieldModel> fields,
  }) async {
    final pdf = pw.Document();

    for (int i = 0; i < document.pagesCount; i++) {
      final pageNum = i + 1;
      final page = await document.getPage(pageNum);
      
      // Render page at high quality (e.g. 3x resolution)
      final pageImage = await page.render(
        width: page.width * 3,
        height: page.height * 3,
        format: px.PdfPageImageFormat.png,
      );
      
      if (pageImage == null) continue;

      final bgImage = pw.MemoryImage(pageImage.bytes);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(page.width, page.height),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Image(bgImage),
                ...fields.where((f) => f.page == pageNum).map((field) {
                  // Coordinate mapping from UI (800 width) to PDF points
                  final double scale = page.width / 800.0;
                  final double left = field.x * scale;
                  final double top = field.y * scale;
                  final double width = field.width * scale;
                  final double height = field.height * scale;

                  if (field.value == null) return pw.SizedBox.shrink();

                  if (field.value is Uint8List) {
                    return pw.Positioned(
                      left: left,
                      top: top,
                      child: pw.Image(
                        pw.MemoryImage(field.value as Uint8List),
                        width: width,
                        height: height,
                      ),
                    );
                  } else if (field.value is String || field.value is bool) {
                    final String text = field.value is bool 
                        ? (field.value as bool ? '✓' : '') 
                        : field.value.toString();
                    
                    return pw.Positioned(
                      left: left,
                      top: top,
                      child: pw.Container(
                        width: width,
                        height: height,
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          text,
                          style: pw.TextStyle(
                            fontSize: 12 * scale,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    );
                  }
                  return pw.SizedBox.shrink();
                }),
              ],
            );
          },
        ),
      );
      
      await page.close();
    }

    return pdf.save();
  }
}

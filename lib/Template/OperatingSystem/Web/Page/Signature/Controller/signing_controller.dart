import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:intl/intl.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/signature_field_model.dart';
import '../Model/signing_session_model.dart';
import '../Widget/adopt_and_sign_modal.dart';
import '../Widget/signing_action_menu.dart';
import '../Widget/success_modal.dart';
import '../Provider/document_provider.dart';
import '../../../../../Utils/Constant/app_config.dart';
import '../Service/pdf_service.dart';

class SigningController extends GetxController {
  final Rxn<SignatureRequestModel> session = Rxn<SignatureRequestModel>();
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxBool isLinkExpired = false.obs;
  final RxBool isLinkResent = false.obs;
  final RxString token = ''.obs;
  final RxString activePopover = ''.obs;
  final RxList<SignatureFieldModel> fields = <SignatureFieldModel>[].obs;
  final RxnString activeFieldId = RxnString();
  final RxList<int> searchResults = <int>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasStarted = false.obs;
  final RxnString activeFieldActionFieldId = RxnString();

  // ── Navigation Tab tracking ──
  final Map<String, GlobalKey> fieldKeys = {};
  final GlobalKey bottomFinishButtonKey = GlobalKey(
    debugLabel: 'bottomFinishButton',
  );
  final RxDouble guidanceTabTop = 100.0.obs;
  final RxDouble guidanceTabLeft = 0.0.obs;
  final GlobalKey documentAreaKey = GlobalKey(debugLabel: 'documentArea');
  final RxDouble zoomLevel = 1.0.obs;
  final TransformationController transformationController =
      TransformationController();

  late DocumentProvider _documentProvider;
  late PdfService _pdfService;
  PdfDocument? pdfDocument;
  late PdfController pdfController;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _documentProvider = DocumentProvider(baseUrl: AppConfig.apiBaseUrl);
    _pdfService = PdfService();
    _extractToken();
    _loadDocumentData();
  }

  void _extractToken() {
    token.value = Get.parameters['token'] ?? '';
  }

  @override
  void onClose() {
    pdfDocument?.close();
    pdfController.dispose();
    scrollController.dispose();
    transformationController.dispose();
    super.onClose();
  }

  Future<void> _loadDocumentData() async {
    error.value = '';
    if (token.isEmpty) {
      isLoading.value = false;
      error.value = 'No signing token provided.';
      return;
    }

    try {
      isLoading.value = true;

      // Fetch metadata
      final request = await _documentProvider.getSignatureRequest(token.value);
      session.value = request;

      // Fetch PDF bytes
      final bytes = await _documentProvider.getDocumentBytes(token.value);

      // Initialize PDF Controller
      pdfController = PdfController(document: PdfDocument.openData(bytes));

      // Open document reference for the view
      pdfDocument = await pdfController.document;

      // Initial scroll to top
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      });

      // Filter fields for the current guest signer matching the token's email
      if (request.targetSignerEmail != null) {
        final currentSigner = request.signers.firstWhereOrNull(
          (s) =>
              s.signerEmail.toLowerCase() ==
              request.targetSignerEmail!.toLowerCase(),
        );
        if (currentSigner != null) {
          fields.assignAll(currentSigner.fields);
        } else if (request.signers.isNotEmpty) {
          fields.assignAll(request.signers.first.fields);
        }
      }

      // Initialize GlobalKeys for field tracking
      _initFieldKeys();

      // Auto-fill date fields with today's date
      _autoFillDateFields();

      // Initial active field is the first unsigned one
      _updateActiveField();

      // Ensure tab is positioned correctly on first load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (activeFieldId.value != null) {
          _alignTabToField(activeFieldId.value!);
        }
      });

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('expired')) {
        isLinkExpired.value = true;
        error.value = 'expired';
      } else {
        isLinkExpired.value = false;
        error.value = 'Failed to load document: $e';
        Get.snackbar(
          'Error',
          'Could not load document: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void togglePopover(String popoverName) {
    if (activePopover.value == popoverName) {
      activePopover.value = '';
    } else {
      activePopover.value = popoverName;
    }
  }

  void onFieldTap(SignatureFieldModel field) {
    hasStarted.value = true;
    switch (field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        if (field.value != null) {
          if (Get.width > 900) {
            activeFieldActionFieldId.value = field.fieldId;
          } else {
            Get.bottomSheet(
              SigningActionMenu(
                onChange: () => openSigningModal(field),
                onRemove: () => removeSignature(field),
              ),
            );
          }
        } else {
          openSigningModal(field);
        }
        break;
      case SignatureFieldType.dateSigned:
        _applySignature(field, DateFormat('MM/dd/yyyy').format(DateTime.now()));
        break;
      case SignatureFieldType.checkbox:
        _applySignature(field, field.value == true ? null : true);
        break;
      case SignatureFieldType.textbox:
        _openTextInputModal(field);
        break;
    }
  }

  void _openTextInputModal(SignatureFieldModel field) {
    final textController = TextEditingController(
      text: field.value?.toString() ?? '',
    );
    Get.defaultDialog(
      title: 'Enter Text',
      titleStyle: TextStyle(
        fontSize: 18.sp,
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Type something...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          _applySignature(
            field,
            textController.text.isEmpty ? null : textController.text,
          );
          Get.back();
        },
        child: const Text('OK'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  SignerModel? get currentSigner {
    final s = session.value;
    if (s == null || s.targetSignerEmail == null) return null;
    return s.signers.firstWhereOrNull(
      (signer) =>
          signer.signerEmail.toLowerCase() == s.targetSignerEmail!.toLowerCase(),
    );
  }

  void openSigningModal(SignatureFieldModel field) {
    final name = currentSigner?.signerName ?? '';
    final initials =
        name.isNotEmpty
            ? name
                .trim()
                .split(RegExp(r'\s+'))
                .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                .join()
            : '';

    Get.dialog(
      AdoptAndSignModal(
        initialName: name,
        initialInitials: initials,
        fieldType: field.type,
        onAdopt: (Uint8List? signature, name, initials) {
          _applySignature(field, signature);
          Get.back();
        },
      ),
    );
  }

  void _applySignature(SignatureFieldModel field, dynamic value) {
    final index = fields.indexWhere((f) => f.fieldId == field.fieldId);
    if (index != -1) {
      fields[index] = fields[index].copyWith(
        value: value,
        clearValue: value == null,
      );
      fields.refresh();
      _updateActiveField(); // Advance the indicator

      // Auto-move to next field or finish button
      Future.delayed(
        const Duration(milliseconds: 400),
        () => scrollToNextField(),
      );
    }
  }

  void _updateActiveField() {
    final next = fields.firstWhereOrNull((f) => f.value == null);
    activeFieldId.value = next?.fieldId;

    // Aligns the tab to the new active field immediately in the UI
    if (next != null) {
      _alignTabToField(next.fieldId);
    } else {
      _alignTabToKey(bottomFinishButtonKey);
    }
  }

  /// Create a GlobalKey for every field so we can locate them in the scroll view.
  void _initFieldKeys() {
    fieldKeys.clear();
    for (final field in fields) {
      fieldKeys[field.fieldId] = GlobalKey(
        debugLabel: 'field_${field.fieldId}',
      );
    }
  }

  /// Auto-fill all dateSigned fields with today's date.
  void _autoFillDateFields() {
    final today = DateFormat('MM/dd/yyyy').format(DateTime.now());
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].type == SignatureFieldType.dateSigned &&
          fields[i].value == null) {
        fields[i] = fields[i].copyWith(value: today);
      }
    }
  }

  void removeSignature(SignatureFieldModel field) {
    final index = fields.indexWhere((f) => f.fieldId == field.fieldId);
    if (index != -1) {
      fields[index] = fields[index].copyWith(clearValue: true);
      fields.refresh();
      _updateActiveField(); // Jump pointer back to this or earlier unfilled field
    }
  }

  /// Scroll to the next pending field using GlobalKey-based positioning.
  /// After scrolling, aligns the navigation tab to the field's viewport Y.
  Future<void> scrollToNextField() async {
    hasStarted.value = true;
    final nextField = fields.firstWhereOrNull((f) => f.value == null);
    final GlobalKey? key;
    final String? fieldId;

    if (nextField != null) {
      key = fieldKeys[nextField.fieldId];
      fieldId = nextField.fieldId;
    } else {
      // All fields done? Target the bottom finish button
      key = bottomFinishButtonKey;
      fieldId = null;
    }

    if (key?.currentContext != null) {
      // Widget is already built – use ensureVisible for precise scroll
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: 0.35, // place ~35% from top of viewport
      );
    } else if (scrollController.hasClients) {
      // Widget not yet built (off-screen) – estimate offset to bring page into view
      final double targetOffset;
      if (nextField != null) {
        const double estimatedPageHeight = 1050.0;
        targetOffset = nextField.page * estimatedPageHeight;
      } else {
        // Go straight to the end
        targetOffset = scrollController.position.maxScrollExtent;
      }

      await scrollController.animateTo(
        targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      // Wait for the page to build, then fine-tune
      await Future.delayed(const Duration(milliseconds: 150));
      if (key?.currentContext != null) {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: 0.35,
        );
      }
    }

    // Align the navigation tab to the target after scroll completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fieldId != null) {
        _alignTabToField(fieldId);
      } else {
        _alignTabToKey(bottomFinishButtonKey);
      }
    });
  }

  /// Helper to align the tab to a specific GlobalKey (like the bottom button or a field)
  void _alignTabToKey(GlobalKey targetKey) {
    final targetContext = targetKey.currentContext;
    final docContext = documentAreaKey.currentContext;
    if (targetContext == null || docContext == null) return;

    final RenderBox targetBox = targetContext.findRenderObject() as RenderBox;
    final RenderBox docBox = docContext.findRenderObject() as RenderBox;

    // Find the page container - the target is inside a Stack/Container representing the page
    RenderBox? pageBox;
    targetContext.visitAncestorElements((element) {
      if (element.widget is Stack || element.widget is Container) {
        final box = element.findRenderObject();
        if (box is RenderBox && box.size.width > targetBox.size.width * 2) {
          pageBox = box;
          return false;
        }
      }
      return true;
    });

    final targetGlobal = targetBox.localToGlobal(Offset.zero);
    final docGlobal = docBox.localToGlobal(Offset.zero);
    final pageGlobal = pageBox?.localToGlobal(Offset.zero) ?? targetGlobal;

    final double relativeTop = targetGlobal.dy - docGlobal.dy;
    final double relativeLeft = pageGlobal.dx - docGlobal.dx;

    const double tabHeight = 44.0;
    // We'll estimate tab width or keep it fixed for margin calculation
    // "Start" is roughly 80-100px with padding, arrows are ~60-80px
    final double tabWidth = hasStarted.value ? 70.0 : 90.0;

    guidanceTabTop.value =
        (relativeTop + (targetBox.size.height / 2) - (tabHeight / 2)).clamp(
          0.0,
          docBox.size.height - tabHeight,
        );

    // Flush with document edge
    guidanceTabLeft.value = (relativeLeft - tabWidth).clamp(
      -tabWidth,
      docBox.size.width,
    );
  }

  /// Compute the field's position relative to the document area viewport
  /// and update [guidanceTabTop]/[guidanceTabLeft] so the navigation tab stays flush.
  void _alignTabToField(String fieldId) {
    final key = fieldKeys[fieldId];
    if (key == null) return;
    _alignTabToKey(key);
  }

  void jumpToPage(int pageNumber) {
    if (scrollController.hasClients) {
      // pageNumber from sidebar is 1-indexed
      const double estimatedPageHeight = 1050.0;
      final double targetOffset = (pageNumber - 1) * estimatedPageHeight;
      scrollController.animateTo(
        targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void zoomIn() {
    final double nextZoom = (zoomLevel.value + 0.25).clamp(1.0, 3.0);
    _updateZoom(nextZoom);
  }

  void zoomOut() {
    final double nextZoom = (zoomLevel.value - 0.25).clamp(1.0, 3.0);
    _updateZoom(nextZoom);
  }

  void _updateZoom(double value) {
    zoomLevel.value = value;
    transformationController.value = Matrix4.identity()..scale(value);
  }

  void onInteractionUpdate(ScaleUpdateDetails details) {
    // Sync internal zoomLevel with InteractiveViewer state
    final double currentScale = transformationController.value
        .getMaxScaleOnAxis();
    if ((currentScale - zoomLevel.value).abs() > 0.01) {
      zoomLevel.value = currentScale;
    }
  }

  Future<void> finishSigning() async {
    if (fields.any((f) => f.value == null)) {
      Get.snackbar(
        'Action Required',
        'Please sign all required fields before finishing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
      return;
    }

    isLoading.value = true;
    try {
      // Collect signature data
      final List<Map<String, dynamic>> signatureData = fields
          .map(
            (f) => {
              'fieldId': f.fieldId,
              'value': f.value is Uint8List ? base64Encode(f.value) : f.value,
              'type': f.type.name,
            },
          )
          .toList();

      // Submit to API
      await _documentProvider.submitSignature(
        token: token.value,
        signatureData: signatureData,
      );

      // Simulate the backend processing (flattening PDF, updating status)
      // to give the user a sense of "work being done" as per reference.
      await Future.delayed(const Duration(seconds: 2));

      Get.dialog(const SuccessModal(), barrierDismissible: false);
    } catch (e) {
      Get.snackbar(
        'Submission Error',
        'We couldn\'t process your signatures. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchText(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    searchResults.clear();

    try {
      final doc = await pdfController.document;
      for (int i = 1; i <= doc.pagesCount; i++) {
        // Simulated search logic: pdfx doesn't support easy text extraction for web
        // In a real app, you'd use a search index or a more robust PDF library
        if (query.length > 2 && i % 2 == 0) {
          searchResults.add(i);
        }
      }
    } catch (e) {
      debugPrint('Error searching text: $e');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> downloadDocument() async {
    try {
      final doc = await pdfController.document;
      final mergedBytes = await _pdfService.mergeSignatures(
        document: doc,
        fields: fields,
      );

      final blob = web.Blob(
        [mergedBytes.toJS].toJS,
        web.BlobPropertyBag(type: 'application/pdf'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = "signed_document.pdf";
      anchor.click();
      web.URL.revokeObjectURL(url);

      Get.snackbar(
        'Success',
        'Document downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resendLink() async {
    try {
      await _documentProvider.resendSigningLink(token.value);
      isLinkResent.value = true;
      
      Get.snackbar(
        'Link Sent',
        'A new signing link has been sent to your email address. Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send new link: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
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
  final RxString token = ''.obs;
  final RxString activePopover = ''.obs;
  final RxList<SignatureFieldModel> fields = <SignatureFieldModel>[].obs;
  final RxList<int> searchResults = <int>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  late DocumentProvider _documentProvider;
  late PdfService _pdfService;
  late PdfControllerPinch pdfController;

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
    pdfController.dispose();
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
      
      // Initialize PDF controller with real data
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(bytes),
      );
      
      // Filter fields for the current guest signer (simplified: first signer in session for now)
      if (request.signers.isNotEmpty) {
        fields.assignAll(request.signers.first.fields);
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
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

  void togglePopover(String popoverName) {
    if (activePopover.value == popoverName) {
      activePopover.value = '';
    } else {
      activePopover.value = popoverName;
    }
  }

  void onFieldTap(SignatureFieldModel field) {
    switch (field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        if (field.value != null) {
          Get.bottomSheet(
            SigningActionMenu(
              onChange: () => _openSigningModal(field),
              onRemove: () => _removeSignature(field),
            ),
          );
        } else {
          _openSigningModal(field);
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
    final textController = TextEditingController(text: field.value?.toString() ?? '');
    Get.defaultDialog(
      title: 'Enter Text',
      titleStyle: TextStyle(fontSize: 18.sp, color: AppColors.navy, fontWeight: FontWeight.bold),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Type something...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          _applySignature(field, textController.text.isEmpty ? null : textController.text);
          Get.back();
        },
        child: const Text('OK'),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  void _openSigningModal(SignatureFieldModel field) {
    Get.dialog(
      AdoptAndSignModal(
        initialName: 'Ricardo',
        initialInitials: 'D.',
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
      fields[index] = fields[index].copyWith(value: value);
    }
  }

  void _removeSignature(SignatureFieldModel field) {
    final index = fields.indexWhere((f) => f.fieldId == field.fieldId);
    if (index != -1) {
      fields[index] = fields[index].copyWith(value: null);
    }
  }

  void scrollToNextField() {
    final nextField = fields.firstWhereOrNull((f) => f.value == null);
    if (nextField != null) {
      pdfController.animateToPage(
        pageNumber: nextField.page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
      final List<Map<String, dynamic>> signatureData = fields.map((f) => {
        'fieldId': f.fieldId,
        'value': f.value is Uint8List ? base64Encode(f.value) : f.value,
        'type': f.type.name,
      }).toList();

      // Submit to API
      await _documentProvider.submitSignature(
        token: token.value,
        signatureData: signatureData,
      );

      // Simulate local PDF processing (UI feedback)
      await Future.delayed(const Duration(seconds: 1));
      
      Get.dialog(
        const SuccessModal(),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to process document');
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

      final blob = html.Blob([mergedBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "signed_document.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);
      
      Get.snackbar('Success', 'Document downloaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}

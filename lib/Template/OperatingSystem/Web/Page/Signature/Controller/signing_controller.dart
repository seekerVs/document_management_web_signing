import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/signature_field_model.dart';
import '../Model/signing_session_model.dart';
import '../Widget/adopt_and_sign_modal.dart';
import '../Widget/signing_action_menu.dart';
import '../Widget/success_modal.dart';

class SigningController extends GetxController {
  final Rxn<SignatureRequestModel> session = Rxn<SignatureRequestModel>();
  final RxBool isLoading = true.obs;
  final RxString token = ''.obs;
  final RxList<SignatureFieldModel> fields = <SignatureFieldModel>[].obs;

  late PdfControllerPinch pdfController;

  @override
  void onInit() {
    super.onInit();
    _extractToken();
    _initPdfController();
    _loadSampleData();
  }

  @override
  void onClose() {
    pdfController.dispose();
    super.onClose();
  }

  void _initPdfController() {
    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/sample.pdf'),
    );
  }

  void _extractToken() {
    token.value = Get.parameters['token'] ?? '';
  }

  void _loadSampleData() {
    fields.add(
      SignatureFieldModel(
        fieldId: 'f1',
        type: SignatureFieldType.signature,
        page: 0,
        x: 440,
        y: 840,
        width: 200,
        height: 48,
      ),
    );
    isLoading.value = false;
  }

  void onFieldTap(SignatureFieldModel field) {
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
  }

  void _openSigningModal(SignatureFieldModel field) {
    Get.dialog(
      AdoptAndSignModal(
        initialName: 'Ricardo',
        initialInitials: 'D.',
        onAdopt: (signature, name, initials) {
          _applySignature(field, signature);
          Get.back();
        },
      ),
    );
  }

  void _applySignature(SignatureFieldModel field, String? signature) {
    final index = fields.indexWhere((f) => f.fieldId == field.fieldId);
    if (index != -1) {
      fields[index] = fields[index].copyWith(value: 'Signed');
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
      Get.snackbar(
        'Guiding',
        'Moving to next field: ${nextField.type.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
      );
    }
  }

  void finishSigning() {
    Get.dialog(
      const SuccessModal(email: 'ricardo1234@gmail.com'),
      barrierDismissible: false,
    );
  }
}

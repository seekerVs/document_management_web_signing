import 'package:flutter/material.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Model/signature_field_model.dart';

class SignatureFieldGuestOverlay extends StatelessWidget {
  final SignatureFieldModel field;
  final VoidCallback onTap;
  final String? signatureData;

  const SignatureFieldGuestOverlay({
    super.key,
    required this.field,
    required this.onTap,
    this.signatureData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSigned = signatureData != null || field.value != null;

    return Positioned(
      left: field.x,
      top: field.y,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: field.width,
          height: field.height,
          decoration: BoxDecoration(
            color: isSigned
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: isSigned
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isSigned)
                Center(child: _buildSignatureDisplay())
              else
                _buildSignBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureDisplay() {
    return Text(
      field.value ?? 'Signed',
      style: const TextStyle(
        fontFamily: 'DancingScript',
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSignBadge() {
    return Positioned(
      top: -12,
      left: (field.width / 2) - 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Sign',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

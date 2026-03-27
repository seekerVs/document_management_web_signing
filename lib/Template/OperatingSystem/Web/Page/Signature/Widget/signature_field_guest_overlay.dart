import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Model/signature_field_model.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';

class SignatureFieldGuestOverlay extends StatelessWidget {
  final SignatureFieldModel field;
  final VoidCallback onTap;
  final double scale;

  const SignatureFieldGuestOverlay({
    super.key,
    required this.field,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: field.x * scale,
      top: field.y * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Target Box
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: field.width * scale,
              height: field.height * scale,
              decoration: BoxDecoration(
                color: field.value == null ? (field.type == SignatureFieldType.checkbox ? Colors.transparent : AppColors.navy) : Colors.transparent,
                border: Border.all(
                  color: field.value == null 
                    ? (field.type == SignatureFieldType.checkbox ? AppColors.navy : Colors.white) 
                    : (field.type == SignatureFieldType.checkbox ? AppColors.navy : Colors.transparent),
                  width: field.type == SignatureFieldType.checkbox ? 2 : 2,
                ),
                borderRadius: BorderRadius.circular(field.type == SignatureFieldType.checkbox ? 2.r : 4.r),
              ),
              child: _buildFieldContent(scale),
            ),
          ),
          // Tooltip
          if (field.value == null && field.type != SignatureFieldType.checkbox)
            Positioned(
              top: -24.h * scale,
              left: 0,
              child: _buildTooltip(scale),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldContent(double scale) {
    if (field.value != null) {
      switch (field.type) {
        case SignatureFieldType.signature:
        case SignatureFieldType.initials:
          if (field.value is Uint8List) {
            return Image.memory(field.value as Uint8List, fit: BoxFit.contain);
          }
          return Center(
            child: Text(
              field.value.toString(),
              style: TextStyle(fontFamily: 'DancingScript', fontSize: 24.sp * scale, color: Colors.black),
            ),
          );
        case SignatureFieldType.checkbox:
          return Center(
            child: Icon(Icons.check, color: AppColors.navy, size: field.height * scale * 0.8),
          );
        case SignatureFieldType.textbox:
        case SignatureFieldType.dateSigned:
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w * scale),
            alignment: Alignment.centerLeft,
            child: Text(
              field.value.toString(),
              style: TextStyle(fontSize: 13.sp * scale, color: Colors.black),
            ),
          );
      }
    }

    // Default "Unsigned/Empty" state
    switch (field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 14.sp * scale),
            SizedBox(width: 4.w * scale),
            Text(
              field.type == SignatureFieldType.signature ? 'Sign' : 'Initial',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp * scale),
            ),
          ],
        );
      case SignatureFieldType.checkbox:
        return const SizedBox.shrink();
      case SignatureFieldType.textbox:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w * scale),
          alignment: Alignment.centerLeft,
          child: Text(
            'Text',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp * scale),
          ),
        );
      case SignatureFieldType.dateSigned:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w * scale),
          alignment: Alignment.centerLeft,
          child: Text(
            'Date',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp * scale),
          ),
        );
    }
  }

  Widget _buildTooltip(double scale) {
    String label = 'Required - ';
    switch (field.type) {
      case SignatureFieldType.signature: label += 'Sign Here'; break;
      case SignatureFieldType.initials: label += 'Initial Here'; break;
      case SignatureFieldType.textbox: label += 'Type Here'; break;
      case SignatureFieldType.dateSigned: label += 'Insert Date'; break;
      case SignatureFieldType.checkbox: label += 'Check'; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w * scale, vertical: 2.h * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10.sp * scale.clamp(0.6, 1.0),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

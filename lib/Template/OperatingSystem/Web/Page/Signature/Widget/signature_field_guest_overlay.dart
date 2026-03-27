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
                color: field.value == null 
                  ? (field.type == SignatureFieldType.checkbox ? Colors.transparent : AppColors.navy.withOpacity(0.08)) 
                  : Colors.transparent,
                border: Border.all(
                  color: field.value == null 
                    ? (field.type == SignatureFieldType.checkbox ? AppColors.navy : AppColors.navy.withOpacity(0.4)) 
                    : (field.type == SignatureFieldType.checkbox ? AppColors.navy : Colors.transparent),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(field.type == SignatureFieldType.checkbox ? 4.r : 6.r),
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              field.type == SignatureFieldType.signature ? Icons.draw : Icons.gesture, 
              color: AppColors.navy, 
              size: (18.sp * scale).clamp(16, 24)
            ),
            if (scale > 0.5) ...[
              SizedBox(height: 2.h * scale),
              Text(
                field.type == SignatureFieldType.signature ? 'Sign' : 'Initial',
                style: TextStyle(
                  color: AppColors.navy, 
                  fontWeight: FontWeight.w600, 
                  fontSize: (11.sp * scale).clamp(10, 14)
                ),
              ),
            ],
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
    String label = '';
    switch (field.type) {
      case SignatureFieldType.signature: label = 'Sign Here'; break;
      case SignatureFieldType.initials: label = 'Initial Here'; break;
      case SignatureFieldType.textbox: label = 'Type Here'; break;
      case SignatureFieldType.dateSigned: label = 'Insert Date'; break;
      case SignatureFieldType.checkbox: label = 'Check'; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white, size: (12.sp * scale).clamp(10, 14)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: (10.sp * scale).clamp(9, 13),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

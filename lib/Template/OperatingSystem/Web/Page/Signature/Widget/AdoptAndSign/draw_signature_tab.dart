import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Utils/Constant/colors.dart';
import 'dashed_rect_painter.dart';

class DrawSignatureTab extends StatelessWidget {
  final SignatureController signatureController;

  const DrawSignatureTab({super.key, required this.signatureController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: AppColors.borderLight,
          strokeWidth: 2,
          gap: 5,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                'Draw your signature',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Signature(
                controller: signatureController,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: InkWell(
                onTap: () => signatureController.clear(),
                child: Icon(
                  Icons.fullscreen,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

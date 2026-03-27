import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Utils/Constant/colors.dart';
import 'dashed_rect_painter.dart';

class UploadSignatureTab extends StatelessWidget {
  const UploadSignatureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      width: double.infinity,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: AppColors.borderLight,
          strokeWidth: 2,
          gap: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.borderLight),
                shadowColor: Colors.transparent,
              ),
              child: const Text('UPLOAD YOUR SIGNATURE'),
            ),
          ],
        ),
      ),
    );
  }
}

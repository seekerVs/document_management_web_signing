import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';

class SuccessModal extends StatelessWidget {
  const SuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 450.w,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderLight, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.borderLight,
              height: 8.h,
            ), // Top accent bar
            Padding(
              padding: EdgeInsets.all(32.w),
              child: Text(
                'Your PDF is being generated. If you have your browser set to save PDF files, you may close this window after the file has downloaded.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 24.w, bottom: 24.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

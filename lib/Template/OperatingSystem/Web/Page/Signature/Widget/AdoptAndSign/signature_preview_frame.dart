import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Utils/Constant/colors.dart';

class SignaturePreviewFrame extends StatelessWidget {
  final String name;
  final String initials;
  final String font;

  const SignaturePreviewFrame({
    super.key,
    required this.name,
    required this.initials,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'Signature' : name;
    final displayInitials = initials.isEmpty ? 'DS' : initials;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Signed by:',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: font,
                    fontSize: 36.sp,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '44FEDE5C148F400...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 60.h,
          color: AppColors.borderLight,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: Text(
                  displayInitials,
                  style: TextStyle(
                    fontFamily: font,
                    fontSize: 36.sp,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

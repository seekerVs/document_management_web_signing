import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';

class SigningFooter extends StatelessWidget {
  const SigningFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24.w,
        vertical: 12.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildBranding(context),
        const Spacer(),
        _buildLinks(context),
        const Spacer(),
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBranding(context),
        SizedBox(height: 8.h),
        _buildLinks(context),
        SizedBox(height: 4.h),
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered by',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textHint,
                fontSize: 10.sp,
              ),
        ),
        SizedBox(width: 6.w),
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: 14.w,
          colorFilter: const ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          'scrivener',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }

  Widget _buildLinks(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFooterLink(context, 'Terms of Use'),
        _buildDivider(),
        _buildFooterLink(context, 'Privacy'),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontSize: 10.sp,
            ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 10.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      color: AppColors.borderLight,
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      'Copyright © 2026 Scrivener, Inc. All rights reserved',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textHint,
            fontSize: 10.sp,
          ),
    );
  }
}

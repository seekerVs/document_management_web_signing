import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Utils/Constant/enum.dart';

class SignaturePreviewFrame extends StatelessWidget {
  final String name;
  final String initials;
  final String font;
  final SignatureFieldType fieldType;
  final GlobalKey? captureKey;

  const SignaturePreviewFrame({
    super.key,
    required this.name,
    required this.initials,
    required this.font,
    required this.fieldType,
    this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildSignatureOnly(context),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: _buildInitialsOnly(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureOnly(BuildContext context) {
    final displayName = name.isEmpty ? 'Signature' : name;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            decoration: BoxDecoration(
              border: Border(
                left: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
                top: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
                bottom: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.r),
                bottomLeft: Radius.circular(3.r),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Signed by:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
                fieldType == SignatureFieldType.signature && captureKey != null
                    ? RepaintBoundary(
                        key: captureKey,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 24.sp,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        displayName,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 24.sp,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                Text(
                  '44FEDE5C148F400...',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black54,
                    fontSize: 7.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsOnly(BuildContext context) {
    final displayInitials = initials.isEmpty ? 'DS' : initials;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            decoration: BoxDecoration(
              border: Border(
                left: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
                top: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
                bottom: const BorderSide(color: Color(0xFF8B8CEB), width: 1.0),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.r),
                bottomLeft: Radius.circular(2.r),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
                fieldType == SignatureFieldType.initials && captureKey != null
                    ? RepaintBoundary(
                        key: captureKey,
                        child: Text(
                          displayInitials,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 24.sp,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        displayInitials,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 24.sp,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

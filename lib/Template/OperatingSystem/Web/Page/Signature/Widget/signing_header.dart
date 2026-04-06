import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';

class SigningHeader extends StatelessWidget {
  final SigningController controller;

  const SigningHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.width <= 900;
    return Container(
      height: isMobile ? 56 : 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review and complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildHeaderActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final bool isMobile = context.width <= 900;
    return Obx(() {
      final bool allDone =
          controller.fields.isNotEmpty &&
          controller.fields.every((f) => f.value != null);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: allDone ? controller.finishSigning : null,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Center(
                        child: Text(
                          'Finish',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: allDone ? Colors.white : Colors.white38,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.white30),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {}, // Dropdown visual for now
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: allDone ? Colors.white : Colors.white38,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'Other Actions',
          ),
        ],
      );
    });
  }
}

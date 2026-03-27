import 'package:flutter/material.dart';
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
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: Colors.white, size: isMobile ? 20 : 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review and complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(() => Text(
                  '${controller.fields.where((f) => f.value != null).length} of ${controller.fields.length} fields completed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Obx(() {
      final bool allDone = controller.fields.isNotEmpty && controller.fields.every((f) => f.value != null);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: allDone ? controller.finishSigning : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              disabledBackgroundColor: Colors.white24,
              disabledForegroundColor: Colors.white38,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              'FINISH',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
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

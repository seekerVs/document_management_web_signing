import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';

class GuidanceButton extends StatelessWidget {
  final SigningController controller;

  const GuidanceButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool allDone = controller.fields.isNotEmpty && controller.fields.every((f) => f.value != null);
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: allDone ? controller.finishSigning : controller.scrollToNextField,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 8,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allDone ? 'FINISH' : 'START',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(allDone ? Icons.check_circle : Icons.arrow_downward, size: 20),
            ],
          ),
        ),
      );
    });
  }
}

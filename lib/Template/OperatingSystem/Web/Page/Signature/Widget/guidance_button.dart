import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signing_controller.dart';
import '../../../../../Utils/Constant/enum.dart';

/// A DocuSign-style left-margin navigation tab that guides users through
/// signature fields. Displays context-aware labels ("Start", "Sign", "Initial", etc.)
/// and vertically aligns itself next to the target action widget.
class NavigationTab extends StatelessWidget {
  final SigningController controller;

  const NavigationTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasFields = controller.fields.isNotEmpty;
      final bool allDone =
          hasFields && controller.fields.every((f) => f.value != null);

      if (!hasFields) return const SizedBox.shrink();

      String label;
      if (allDone) {
        label = 'Finish';
      } else if (!controller.hasStarted.value) {
        label = 'Start';
      } else {
        final activeField = controller.fields.firstWhereOrNull(
          (f) => f.fieldId == controller.activeFieldId.value,
        );

        if (activeField != null) {
          label = switch (activeField.type) {
            SignatureFieldType.signature => 'Sign',
            SignatureFieldType.initials => 'Initial',
            SignatureFieldType.checkbox => 'Check',
            SignatureFieldType.textbox => 'Text',
            SignatureFieldType.dateSigned => 'Date',
          };
        } else {
          label = 'Next';
        }
      }

      final bool isRect = label == 'Start';
      final IconData? icon = allDone
          ? null
          : Icons.arrow_forward_rounded;
      final Color tabColor = allDone ? AppColors.success : AppColors.primary;

      return GestureDetector(
        onTap: controller.scrollToNextField,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: _TabShape(
            color: tabColor,
            isRect: isRect,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                if (!isRect && icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Draws the arrow-shaped tab body pointing to the right,
/// or a rectangular box, flush with the left edge of the document.
class _TabShape extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool isRect;

  const _TabShape({
    required this.child,
    required this.color,
    this.isRect = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TabShapePainter(color: color, isRect: isRect),
      child: Padding(
        padding: isRect
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : const EdgeInsets.only(left: 14, right: 22, top: 11, bottom: 11),
        child: child,
      ),
    );
  }
}

/// Custom painter for a right-pointing tab shape or a rectangle with a subtle shadow.
/// Left side is flat (flush with margin), right side terminates in an arrow.
class _TabShapePainter extends CustomPainter {
  final Color color;
  final bool isRect;

  _TabShapePainter({required this.color, this.isRect = false});

  @override
  void paint(Canvas canvas, Size size) {
    const double arrowWidth = 14;
    final double bodyWidth = size.width - arrowWidth;

    final path = Path();
    if (isRect) {
      path.addRRect(
        RRect.fromLTRBR(
          0,
          0,
          size.width,
          size.height,
          const Radius.circular(4),
        ),
      );
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(bodyWidth, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(bodyWidth, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    // Shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.35), 4, true);
    // Fill
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TabShapePainter oldDelegate) =>
      color != oldDelegate.color;
}

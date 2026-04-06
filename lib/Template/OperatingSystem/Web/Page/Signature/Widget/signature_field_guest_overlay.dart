import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/signature_field_model.dart';
import '../Controller/signing_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import 'field_action_popover.dart';

class SignatureFieldGuestOverlay extends StatefulWidget {
  final SignatureFieldModel field;
  final VoidCallback onTap;
  final double pageWidth;
  final double pageHeight;
  final GlobalKey? fieldKey;
  final bool isActive;
  final bool hasStarted;

  const SignatureFieldGuestOverlay({
    super.key,
    required this.field,
    required this.onTap,
    required this.pageWidth,
    required this.pageHeight,
    this.fieldKey,
    this.isActive = false,
    this.hasStarted = false,
  });

  @override
  State<SignatureFieldGuestOverlay> createState() => _SignatureFieldGuestOverlayState();
}

class _SignatureFieldGuestOverlayState extends State<SignatureFieldGuestOverlay> {
  final LayerLink _layerLink = LayerLink();
  late SigningController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SigningController>();
  }

  // Scale factor for internal UI elements (icons, text) relative to a 600px reference page
  double get _scale => (widget.pageWidth / 600.0).clamp(0.5, 1.2);

  // Max rendered field sizes in pixels — prevents fields from ballooning on large screens
  static const double _maxFieldW = 50.0;
  static const double _maxFieldH = 50.0;
  static const double _maxRectW = 100.0;
  static const double _maxRectH = 28.0;

  @override
  Widget build(BuildContext context) {
    final bool isUnsigned = widget.field.value == null;

    final bool isRect =
        widget.field.type == SignatureFieldType.textbox ||
        widget.field.type == SignatureFieldType.dateSigned;

    // Compute rendered size: normalized value * page dimension, clamped to a max
    final double renderWidth = (widget.field.width * widget.pageWidth).clamp(
      20.0,
      isRect ? _maxRectW : _maxFieldW,
    );
    final double renderHeight = (widget.field.height * widget.pageHeight).clamp(
      20.0,
      isRect ? _maxRectH : _maxFieldH,
    );

    return Positioned(
      left: widget.field.x * widget.pageWidth,
      top: widget.field.y * widget.pageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Target Box
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              key: widget.fieldKey,
              onTap: widget.onTap,
              child: Container(
                width: renderWidth,
                height: renderHeight,
                decoration: BoxDecoration(
                  color: isUnsigned
                      ? (widget.field.type == SignatureFieldType.checkbox
                            ? Colors.transparent
                            : AppColors.primary)
                      : Colors.transparent,
                  border: Border.all(
                    color: isUnsigned
                        ? AppColors.primary
                        : (widget.field.type == SignatureFieldType.checkbox
                              ? AppColors.primary
                              : Colors.transparent),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow:
                      isUnsigned && widget.field.type != SignatureFieldType.checkbox
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: _buildFieldContent(_scale),
              ),
            ),
          ),

          // Desktop Action Popover (Change/Clear)
          Obx(() {
            if (controller.activeFieldActionFieldId.value == widget.field.fieldId) {
              return CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: FieldActionPopover(
                  onChange: () {
                    controller.activeFieldActionFieldId.value = null;
                    controller.openSigningModal(widget.field);
                  },
                  onRemove: () {
                    controller.activeFieldActionFieldId.value = null;
                    controller.removeSignature(widget.field);
                  },
                  onClose: () => controller.activeFieldActionFieldId.value = null,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // "Required - Sign Here" label
          if (widget.isActive &&
              widget.hasStarted &&
              isUnsigned &&
              widget.field.type != SignatureFieldType.checkbox)
            Positioned(
              top: -16 * _scale,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'Required - Sign Here',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: (8 * _scale).clamp(7.0, 10.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldContent(double scale) {
    if (widget.field.value != null) {
      switch (widget.field.type) {
        case SignatureFieldType.signature:
        case SignatureFieldType.initials:
          if (widget.field.value is Uint8List) {
            return Transform.scale(
              scale: 1.8,
              child: Image.memory(
                widget.field.value as Uint8List,
                fit: BoxFit.contain,
              ),
            );
          }
          return Center(
            child: Text(
              widget.field.value.toString(),
              style: TextStyle(
                fontFamily: 'DancingScript',
                fontSize: (18 * scale).clamp(12.0, 22.0),
                color: Colors.black,
              ),
            ),
          );
        case SignatureFieldType.checkbox:
          return Center(
            child: Icon(
              Icons.check,
              color: AppColors.primary,
              size: widget.field.height * scale * 0.8,
            ),
          );
        case SignatureFieldType.textbox:
        case SignatureFieldType.dateSigned:
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.field.value.toString(),
              style: TextStyle(
                fontSize: (11 * scale).clamp(9.0, 14.0),
                color: Colors.black,
              ),
            ),
          );
      }
    }

    // Default "Unsigned/Empty" state: Matches mobile "placement" design
    switch (widget.field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_outlined, // More professional "pen" icon
              color: Colors.white,
              size: (14 * scale).clamp(12.0, 20.0),
            ),
            if (scale > 0.4) ...[
              SizedBox(height: 1 * scale),
              Text(
                widget.field.type == SignatureFieldType.signature ? 'Sign' : 'Initial',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: (9 * scale).clamp(8.0, 12.0),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        );
      case SignatureFieldType.checkbox:
        return const SizedBox.shrink();
      case SignatureFieldType.textbox:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * scale,
            vertical: 2 * scale,
          ),
          alignment: Alignment.topLeft,
          child: Text(
            'Add Text',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: (8 * scale).clamp(7.0, 10.0),
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      case SignatureFieldType.dateSigned:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * scale,
            vertical: 2 * scale,
          ),
          alignment: Alignment.topLeft,
          child: Text(
            'Date Signed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: (8 * scale).clamp(7.0, 10.0),
              fontWeight: FontWeight.w300,
            ),
          ),
        );
    }
  }
}

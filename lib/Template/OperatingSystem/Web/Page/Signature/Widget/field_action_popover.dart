import 'package:flutter/material.dart';
import '../../../../../Utils/Constant/colors.dart';

class FieldActionPopover extends StatelessWidget {
  final VoidCallback onChange;
  final VoidCallback onRemove;
  final VoidCallback onClose;

  const FieldActionPopover({
    super.key,
    required this.onChange,
    required this.onRemove,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PopoverItem(
              label: 'Change',
              onTap: onChange,
              isChange: true,
            ),
            const SizedBox(height: 4),
            _PopoverItem(
              label: 'Clear',
              onTap: onRemove,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopoverItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isChange;

  const _PopoverItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isChange = false,
  });

  @override
  State<_PopoverItem> createState() => _PopoverItemState();
}

class _PopoverItemState extends State<_PopoverItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool showBorder = widget.isChange && _isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovering && !widget.isChange
                ? Colors.black.withOpacity(0.03)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: showBorder ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isDestructive ? AppColors.error : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}

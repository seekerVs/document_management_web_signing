import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SigningActionMenu extends StatelessWidget {
  final VoidCallback onChange;
  final VoidCallback onRemove;

  const SigningActionMenu({
    super.key,
    required this.onChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _ActionItem(
            label: 'Change',
            onTap: () {
              Get.back();
              onChange();
            },
            isDestructive: false,
          ),
          const Divider(height: 1),
          _ActionItem(
            label: 'Remove',
            onTap: () {
              Get.back();
              onRemove();
            },
            isDestructive: true,
          ),
          const Divider(height: 1),
          _ActionItem(
            label: 'Cancel',
            onTap: () => Get.back(),
            isDestructive: false,
            isBold: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isBold;

  const _ActionItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black,
              fontSize: 18,
              fontWeight: isBold || isDestructive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

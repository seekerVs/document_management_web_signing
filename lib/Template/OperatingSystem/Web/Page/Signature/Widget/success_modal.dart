import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';

class SuccessModal extends StatelessWidget {
  final String email;

  const SuccessModal({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log in to Scrivener',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: const Text(
                'A copy of this document has been saved to your Scrivener account. Please log in to view it.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('LOG IN'),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () => Get.offAllNamed('/'),
                  child: const Text(
                    'NO THANKS',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

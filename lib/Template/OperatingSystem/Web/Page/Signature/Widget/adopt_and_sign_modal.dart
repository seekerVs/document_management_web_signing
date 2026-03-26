import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../../../Utils/Constant/colors.dart';

class AdoptAndSignModal extends StatefulWidget {
  final String initialName;
  final String initialInitials;
  final Function(String? signature, String name, String initials) onAdopt;

  const AdoptAndSignModal({
    super.key,
    required this.initialName,
    required this.initialInitials,
    required this.onAdopt,
  });

  @override
  State<AdoptAndSignModal> createState() => _AdoptAndSignModalState();
}

class _AdoptAndSignModalState extends State<AdoptAndSignModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _initialsController;
  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: widget.initialName);
    _initialsController = TextEditingController(text: widget.initialInitials);
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _initialsController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review and complete',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confirm your name, initials, and signature.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInput('Full Name *', _nameController),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildInput('Initials *', _initialsController)),
              ],
            ),
            const SizedBox(height: 32),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.black,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'SELECT STYLE'),
                Tab(text: 'DRAW'),
                Tab(text: 'UPLOAD'),
              ],
            ),
            const Divider(height: 0),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStyleTab(),
                  _buildDrawTab(),
                  _buildUploadTab(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'By selecting Adopt and Sign, I agree that the signature and initials will be the electronic representation of my signature and initials for all purposes when I (or my agent) use them on documents, including legally binding contracts.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onAdopt(
                      'dummy_signature',
                      _nameController.text,
                      _initialsController.text,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Adopt and Sign'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: AppColors.borderLight),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
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

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Preview your signature',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? 'Signature' : _nameController.text,
            style: const TextStyle(
              fontFamily: 'DancingScript',
              fontSize: 48,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawTab() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          Signature(
            controller: _signatureController,
            backgroundColor: Colors.transparent,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: TextButton(
              onPressed: () => _signatureController.clear(),
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return const Center(child: Text('Upload feature coming soon'));
  }
}

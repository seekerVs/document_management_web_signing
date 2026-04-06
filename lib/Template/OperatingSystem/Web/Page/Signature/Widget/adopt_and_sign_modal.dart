import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import 'AdoptAndSign/draw_signature_tab.dart';
import 'AdoptAndSign/signature_preview_frame.dart';
import 'AdoptAndSign/upload_signature_tab.dart';

class AdoptAndSignModal extends StatefulWidget {
  final String initialName;
  final String initialInitials;
  final SignatureFieldType fieldType;
  final Function(Uint8List? signature, String name, String initials) onAdopt;

  const AdoptAndSignModal({
    super.key,
    required this.initialName,
    required this.initialInitials,
    required this.fieldType,
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
  final GlobalKey _previewKey = GlobalKey();
  bool _showStyles = false;
  String _selectedFont = 'DancingScript';

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
    final bool isMobile = context.width <= 900;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24.w,
        vertical: isMobile ? 32 : 24.h,
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Content
            Container(
              width: isMobile ? context.width - 24 : 600.w,
              decoration: AppStyle.card(radius: _showStyles ? 0 : 8.r).copyWith(
                borderRadius: _showStyles
                    ? BorderRadius.horizontal(left: Radius.circular(8.r))
                    : BorderRadius.circular(8.r),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Full Name'),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _nameController,
                                      hintText: 'Full Name',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Initials'),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _initialsController,
                                      hintText: 'Initials',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildTabs(),
                          SizedBox(
                            height: 200.h,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildStyleTab(),
                                DrawSignatureTab(
                                  signatureController: _signatureController,
                                ),
                                const UploadSignatureTab(),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'By selecting Adopt and Sign, I agree that the signature and initials will be the electronic representation of my signature and initials for all purposes when I (or my agent) use them on documents, including legally binding contracts.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.sp,
                                ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _nameController,
                                builder: (context, nameVal, _) {
                                  return ValueListenableBuilder<
                                    TextEditingValue
                                  >(
                                    valueListenable: _initialsController,
                                    builder: (context, initialsVal, _) {
                                      final bool isEnabled =
                                          nameVal.text.isNotEmpty &&
                                          initialsVal.text.isNotEmpty;
                                      return ElevatedButton(
                                        onPressed: isEnabled ? _handleAdopt : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24.w,
                                            vertical: 16.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Adopt and Sign',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 16.w),
                              TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 16.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Style Panel
            if (_showStyles)
              Container(
                width: 300.w,
                decoration: AppStyle.card(radius: 0).copyWith(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(8.r),
                  ),
                  border: const Border(
                    left: BorderSide(color: AppColors.borderLight),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: _buildStyleSelector(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Adopt Your Signature',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'SELECT STYLE'),
          Tab(text: 'DRAW'),
          Tab(text: 'UPLOAD'),
        ],
      ),
    );
  }

  Widget _buildStyleTab() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PREVIEW',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showStyles = !_showStyles;
                });
              },
              child: Text(
                'Change Style',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: AppStyle.card(radius: 8.r),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameController,
            builder: (context, nameValue, child) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _initialsController,
                builder: (context, initialValue, child) {
                  return SignaturePreviewFrame(
                    name: nameValue.text,
                    initials: initialValue.text,
                    font: _selectedFont,
                    fieldType: widget.fieldType,
                    captureKey: _previewKey,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    final List<String> mockFonts = [
      'DancingScript',
      'GreatVibes',
      'Pacifico',
      'Satisfy',
      'Kameron',
      'DancingScript', // repeating some for list length
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: mockFonts.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedFont = mockFonts[index];
                    _showStyles = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: AppStyle.card(radius: 8.r).copyWith(
                    border: Border.all(
                      color: _selectedFont == mockFonts[index]
                          ? AppColors.primary
                          : AppColors.borderLight,
                    ),
                  ),
                  child: SignaturePreviewFrame(
                    name: _nameController.text,
                    initials: _initialsController.text,
                    font: mockFonts[index],
                    fieldType: widget.fieldType,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleAdopt() async {
    Uint8List? signatureBytes;

    if (_tabController.index == 0) {
      // 1. SELECT STYLE: Capture the RepaintBoundary
      try {
        RenderRepaintBoundary? boundary =
            _previewKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          var image = await boundary.toImage(pixelRatio: 3.0);
          var byteData = await image.toByteData(format: ImageByteFormat.png);
          signatureBytes = byteData?.buffer.asUint8List();
        }
      } catch (e) {
        debugPrint('Error capturing style signature: $e');
      }
    } else if (_tabController.index == 1) {
      // 2. DRAW: Get bytes from controller
      if (_signatureController.isNotEmpty) {
        signatureBytes = await _signatureController.toPngBytes();
      }
    } else {
      // 3. UPLOAD: TODO: Handle upload bytes
    }

    widget.onAdopt(
      signatureBytes,
      _nameController.text,
      _initialsController.text,
    );
  }
}

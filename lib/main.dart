import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Template/Utils/Constant/colors.dart';
import 'Template/OperatingSystem/Web/Page/Signature/View/signing_view.dart';
import 'Template/OperatingSystem/Web/Page/Signature/Controller/signing_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scrivener Guest Signing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ),
      initialRoute: '/sign/test-token',
      getPages: [
        GetPage(
          name: '/sign/:token',
          page: () => const SigningView(),
          binding: BindingsBuilder(() {
            Get.put(SigningController());
          }),
        ),
      ],
    );
  }
}

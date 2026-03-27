import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'Template/Utils/Constant/colors.dart';
import 'Template/OperatingSystem/Web/Page/Signature/View/signing_view.dart';
import 'Template/OperatingSystem/Web/Page/Signature/Controller/signing_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 832),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              binding: BindingsBuilder(() {
                final token = Get.parameters['token'];
                if (token != null && token.isNotEmpty) {
                  Future.microtask(() => Get.offNamed('/sign/$token'));
                } else {
                  // Fallback or show error
                  Future.microtask(() => Get.offNamed('/sign/error'));
                }
              }),
            ),
            GetPage(
              name: '/sign/:token',
              page: () => const SigningView(),
              binding: BindingsBuilder(() {
                Get.put(SigningController());
              }),
            ),
          ],
        );
      },
    );
  }
}

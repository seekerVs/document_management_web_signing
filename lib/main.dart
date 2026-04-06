import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Template/Utils/Themes/theme.dart';
import 'Template/OperatingSystem/Web/Page/Signature/View/signing_view.dart';
import 'Template/OperatingSystem/Web/Page/Signature/Controller/signing_controller.dart';



void main() {
  usePathUrlStrategy();
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
          theme: AppTheme.light,
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

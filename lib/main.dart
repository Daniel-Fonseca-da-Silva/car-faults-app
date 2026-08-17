import 'package:flutter/material.dart';

import 'ui/core/constants/app_brand.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/login/views/login_view.dart';

void main() {
  runApp(const CarFaultsApp());
}

class CarFaultsApp extends StatelessWidget {
  const CarFaultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBrand.displayName,
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const LoginView(),
    );
  }
}

import 'package:flutter/material.dart';

import 'widgets/login_header.dart';
import 'widgets/login_hero_section.dart';

/// Login screen. Static UI only in this slice: header + hero.
///
/// Google access, stats and footer are added by later slices as sibling
/// widgets inside the same [Column].
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [LoginHeader(), LoginHeroSection()]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_header.dart';
import 'app_nav_drawer.dart';

/// Shared page shell: fixed [AppHeader], right-side [AppNavDrawer], and a
/// scrollable [body] below.
///
/// Every top-level screen except [LegalView] (which uses a plain [AppBar])
/// wraps its content in this so the header and drawer wiring lives in one
/// place.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppNavDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

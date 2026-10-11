import 'package:flutter/material.dart';

import '../../../domain/models/app_locale.dart';

/// Small rectangular flag for [locale], drawn in code.
///
/// No bundled flag artwork ships with the app, so each flag is approximated
/// with its national colors rather than a bitmap/vector asset.
class LocaleFlag extends StatelessWidget {
  const LocaleFlag({super.key, required this.locale});

  final AppLocale locale;

  static const _width = 20.0;
  static const _height = 14.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: _width,
        height: _height,
        child: CustomPaint(painter: _LocaleFlagPainter(locale)),
      ),
    );
  }
}

class _LocaleFlagPainter extends CustomPainter {
  const _LocaleFlagPainter(this.locale);

  final AppLocale locale;

  static const _ptGreen = Color(0xFF046A38);
  static const _ptRed = Color(0xFFDA291C);
  static const _gbBlue = Color(0xFF00247D);
  static const _esRed = Color(0xFFAA151B);
  static const _esYellow = Color(0xFFF1BF00);
  static const _brGreen = Color(0xFF009C3B);
  static const _brYellow = Color(0xFFFFDF00);
  static const _brBlue = Color(0xFF002776);
  static const _frBlue = Color(0xFF002654);
  static const _frRed = Color(0xFFCE1126);

  @override
  void paint(Canvas canvas, Size size) {
    switch (locale) {
      case AppLocale.pt:
        _paintPt(canvas, size);
      case AppLocale.ptBr:
        _paintBr(canvas, size);
      case AppLocale.en:
        _paintGb(canvas, size);
      case AppLocale.es:
        _paintEs(canvas, size);
      case AppLocale.fr:
        _paintFr(canvas, size);
    }
  }

  void _paintPt(Canvas canvas, Size size) {
    final splitX = size.width * 0.4;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, splitX, size.height),
      Paint()..color = _ptGreen,
    );
    canvas.drawRect(
      Rect.fromLTWH(splitX, 0, size.width - splitX, size.height),
      Paint()..color = _ptRed,
    );
    canvas.drawCircle(
      Offset(splitX, size.height / 2),
      size.height * 0.28,
      Paint()..color = _esYellow,
    );
  }

  void _paintBr(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _brGreen);

    final insetX = size.width * 0.1;
    final insetY = size.height * 0.14;
    final rhombus = Path()
      ..moveTo(size.width / 2, insetY)
      ..lineTo(size.width - insetX, size.height / 2)
      ..lineTo(size.width / 2, size.height - insetY)
      ..lineTo(insetX, size.height / 2)
      ..close();
    canvas.drawPath(rhombus, Paint()..color = _brYellow);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.2,
      Paint()..color = _brBlue,
    );
  }

  void _paintGb(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _gbBlue);

    final whiteThick = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.32;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), whiteThick);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), whiteThick);

    final redThin = Paint()
      ..color = _ptRed
      ..strokeWidth = size.height * 0.14;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), redThin);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), redThin);

    final whiteCross = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.36, size.width, size.height * 0.28),
      whiteCross,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height),
      whiteCross,
    );

    final redCross = Paint()..color = _ptRed;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.16),
      redCross,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.44, 0, size.width * 0.12, size.height),
      redCross,
    );
  }

  void _paintEs(Canvas canvas, Size size) {
    final bandHeight = size.height / 4;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, bandHeight),
      Paint()..color = _esRed,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, bandHeight, size.width, bandHeight * 2),
      Paint()..color = _esYellow,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, bandHeight * 3, size.width, bandHeight),
      Paint()..color = _esRed,
    );
  }

  void _paintFr(Canvas canvas, Size size) {
    final bandWidth = size.width / 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, bandWidth, size.height),
      Paint()..color = _frBlue,
    );
    canvas.drawRect(
      Rect.fromLTWH(bandWidth, 0, bandWidth, size.height),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(bandWidth * 2, 0, bandWidth, size.height),
      Paint()..color = _frRed,
    );
  }

  @override
  bool shouldRepaint(covariant _LocaleFlagPainter oldDelegate) =>
      oldDelegate.locale != locale;
}

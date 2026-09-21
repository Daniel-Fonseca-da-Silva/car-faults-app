import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Small white QR code tile, generated on-device from [data]. Mirrors the
/// web Support page's server-rendered QR codes (Wise / Pix payment links).
class SupportQrCode extends StatelessWidget {
  const SupportQrCode({
    super.key,
    required this.data,
    required this.semanticsLabel,
  });

  final String data;
  final String semanticsLabel;

  static const _size = 120.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: QrImageView(
          data: data,
          size: _size,
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

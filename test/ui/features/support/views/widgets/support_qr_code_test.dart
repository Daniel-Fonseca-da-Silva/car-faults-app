import 'package:car_faults_app/ui/features/support/views/widgets/support_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget _app() {
  return const MaterialApp(
    home: Scaffold(
      body: SupportQrCode(
        data: 'https://wise.com/pay/me/danielf6030',
        semanticsLabel: 'Código QR para pagar pela Wise',
      ),
    ),
  );
}

void main() {
  testWidgets('renders a QR code with the given semantics label', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app());

    expect(find.bySemanticsLabel('Código QR para pagar pela Wise'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);

    handle.dispose();
  });
}

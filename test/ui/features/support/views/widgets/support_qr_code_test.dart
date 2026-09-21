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
    await tester.pumpWidget(_app());

    // QrImageView nests its own unlabelled Semantics node inside this
    // widget's, so the label merges upward in the semantics tree and isn't
    // reliably findable via `find.bySemanticsLabel`. Check the Semantics
    // widget's `label` property directly instead.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Código QR para pagar pela Wise',
      ),
      findsOneWidget,
    );
    expect(find.byType(QrImageView), findsOneWidget);
  });
}

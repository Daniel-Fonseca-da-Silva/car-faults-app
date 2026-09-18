import 'package:car_faults_app/domain/models/report_reason.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/report_content_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(void Function((ReportReason, String?)? result) onResult) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          onResult(await showReportContentDialog(context));
        },
        child: const Text('open'),
      ),
    ),
  );
}

void main() {
  testWidgets('the submit button stays disabled until a reason is picked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app((_) {}));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final submitButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Enviar denúncia'),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('picking a reason and submitting returns it with the details', (
    WidgetTester tester,
  ) async {
    (ReportReason, String?)? result;
    await tester.pumpWidget(_app((value) => result = value));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Assédio'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Comentários hostis.');
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Enviar denúncia'));
    await tester.pumpAndSettle();

    expect(result, (ReportReason.harassment, 'Comentários hostis.'));
  });

  testWidgets('cancelling returns null', (WidgetTester tester) async {
    (ReportReason, String?)? result = (ReportReason.spam, 'placeholder');
    await tester.pumpWidget(_app((value) => result = value));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}

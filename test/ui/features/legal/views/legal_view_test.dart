import 'package:car_faults_app/data/repositories/legal_repository.dart';
import 'package:car_faults_app/data/services/legal_document_service.dart';
import 'package:car_faults_app/domain/models/legal_content.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/features/legal/view_models/legal_view_model.dart';
import 'package:car_faults_app/ui/features/legal/views/legal_view.dart';
import 'package:car_faults_app/ui/features/legal/views/widgets/legal_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeLegalRepository extends LegalRepository {
  _FakeLegalRepository({this.content, this.error})
    : super(service: LegalDocumentService());

  final LegalContent? content;
  final Object? error;

  @override
  Future<LegalContent> load(String languageCode) {
    if (error != null) return Future.error(error!);
    return Future.value(content!);
  }
}

LegalContent _sampleContent() {
  return const LegalContent(
    heroEyebrow: 'Legal',
    heroTitle: 'Privacidade e Termos de Uso',
    heroImageAlt: 'Documentos de um Fiat 500',
    navPrivacy: 'Política de Privacidade',
    navTerms: 'Termos de Serviço',
    policy: LegalDocument(
      title: 'Política de Privacidade e Proteção de Dados',
      effectiveDate: 'Data de vigência: 14 de agosto de 2026',
      lastUpdated: 'Última atualização: 14 de agosto de 2026',
      sections: [
        LegalSection(
          id: 'scope',
          heading: '1. Introdução e Âmbito',
          paragraphs: ['Parágrafo da política.'],
        ),
      ],
    ),
    terms: LegalDocument(
      title: 'Termos de Serviço',
      effectiveDate: 'Data de vigência: 14 de agosto de 2026',
      lastUpdated: 'Última atualização: 14 de agosto de 2026',
      sections: [
        LegalSection(
          id: 'provider',
          heading: '1. Prestador',
          paragraphs: ['Parágrafo dos termos.'],
        ),
      ],
    ),
  );
}

Widget _app({
  required LegalRepository repository,
  LegalSectionTarget initialSection = LegalSectionTarget.privacy,
}) {
  return ChangeNotifierProvider(
    create: (_) => LegalViewModel(repository: repository),
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LegalView(initialSection: initialSection),
    ),
  );
}

void main() {
  testWidgets('LegalView shows the hero and both document titles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeLegalRepository(content: _sampleContent())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LegalHero), findsOneWidget);
    expect(find.text('Privacidade e Termos de Uso'), findsOneWidget);
    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text('Termos de Serviço'), findsNWidgets(2));
    expect(
      find.text('Política de Privacidade e Proteção de Dados'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Terms in the nav scrolls to the terms document', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeLegalRepository(content: _sampleContent())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Termos de Serviço').first);
    await tester.pumpAndSettle();

    expect(find.text('1. Prestador'), findsOneWidget);
    expect(find.text('Parágrafo dos termos.'), findsOneWidget);
  });

  testWidgets('LegalView shows an error state with a retry action', (
    WidgetTester tester,
  ) async {
    final repository = _FakeLegalRepository(error: Exception('boom'));

    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar o documento legal.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:car_faults_app/data/repositories/legal_repository.dart';
import 'package:car_faults_app/data/services/legal_document_service.dart';
import 'package:car_faults_app/domain/models/legal_content.dart';
import 'package:car_faults_app/ui/features/legal/view_models/legal_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLegalRepository extends LegalRepository {
  _FakeLegalRepository({this.content, this.error})
    : super(service: LegalDocumentService());

  final LegalContent? content;
  final Object? error;
  final completer = Completer<LegalContent>();
  var useCompleter = false;
  var callCount = 0;
  String? lastLanguageCode;

  @override
  Future<LegalContent> load(String languageCode) {
    callCount++;
    lastLanguageCode = languageCode;
    if (useCompleter) return completer.future;
    if (error != null) return Future.error(error!);
    return Future.value(content!);
  }
}

LegalContent _sampleContent() {
  return const LegalContent(
    heroEyebrow: 'Legal',
    heroTitle: 'Privacy and Terms',
    heroImageAlt: 'Fiat docs',
    navPrivacy: 'Privacy Policy',
    navTerms: 'Terms of Service',
    policy: LegalDocument(
      title: 'Privacy Policy',
      effectiveDate: 'Effective',
      lastUpdated: 'Updated',
      sections: [
        LegalSection(id: 'scope', heading: '1. Scope', paragraphs: ['Body']),
      ],
    ),
    terms: LegalDocument(
      title: 'Terms of Service',
      effectiveDate: 'Effective',
      lastUpdated: 'Updated',
      sections: [
        LegalSection(
          id: 'provider',
          heading: '1. Provider',
          paragraphs: ['Body'],
        ),
      ],
    ),
  );
}

void main() {
  test('load exposes content and clears loading on success', () async {
    final repository = _FakeLegalRepository(content: _sampleContent());
    final viewModel = LegalViewModel(repository: repository);

    await viewModel.load('pt');

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.content?.heroTitle, 'Privacy and Terms');
    expect(viewModel.errorMessage, isNull);
    expect(repository.lastLanguageCode, 'pt');
  });

  test('load sets isLoading while the call is in flight', () async {
    final repository = _FakeLegalRepository(content: _sampleContent())
      ..useCompleter = true;
    final viewModel = LegalViewModel(repository: repository);

    final future = viewModel.load('en');

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.content, isNull);

    repository.completer.complete(_sampleContent());
    await future;

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.content, isNotNull);
  });

  test('load ignores a second call while one is in flight', () async {
    final repository = _FakeLegalRepository(content: _sampleContent())
      ..useCompleter = true;
    final viewModel = LegalViewModel(repository: repository);

    final first = viewModel.load('pt');
    final second = viewModel.load('en');

    repository.completer.complete(_sampleContent());
    await first;
    await second;

    expect(repository.callCount, 1);
  });

  test('load skips reload when the same language is already cached', () async {
    final repository = _FakeLegalRepository(content: _sampleContent());
    final viewModel = LegalViewModel(repository: repository);

    await viewModel.load('pt');
    await viewModel.load('pt');

    expect(repository.callCount, 1);
  });

  test('load reloads when the language code changes', () async {
    final repository = _FakeLegalRepository(content: _sampleContent());
    final viewModel = LegalViewModel(repository: repository);

    await viewModel.load('pt');
    await viewModel.load('en');

    expect(repository.callCount, 2);
    expect(repository.lastLanguageCode, 'en');
  });

  test('load stores a generic error message on failure', () async {
    final repository = _FakeLegalRepository(error: Exception('boom'));
    final viewModel = LegalViewModel(repository: repository);

    await viewModel.load('pt');

    expect(viewModel.content, isNull);
    expect(viewModel.errorMessage, 'load_failed');
    expect(viewModel.isLoading, isFalse);
  });

  test('reload forces a fresh fetch for the same language', () async {
    final repository = _FakeLegalRepository(content: _sampleContent());
    final viewModel = LegalViewModel(repository: repository);

    await viewModel.load('pt');
    await viewModel.reload('pt');

    expect(repository.callCount, 2);
  });

  test('load notifies listeners on start and on completion', () async {
    final repository = _FakeLegalRepository(content: _sampleContent());
    final viewModel = LegalViewModel(repository: repository);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load('pt');

    expect(notifications, 2);
  });
}

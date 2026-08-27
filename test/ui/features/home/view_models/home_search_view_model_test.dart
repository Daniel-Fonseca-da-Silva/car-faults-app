import 'dart:async';

import 'package:car_faults_app/ui/features/home/view_models/home_search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canSubmit is false when every field is empty', () {
    final viewModel = HomeSearchViewModel();

    expect(viewModel.canSubmit, isFalse);
  });

  test('canSubmit is true with only a brand', () {
    final viewModel = HomeSearchViewModel()..setBrand('Volkswagen');

    expect(viewModel.canSubmit, isTrue);
  });

  test('canSubmit is true with only a model', () {
    final viewModel = HomeSearchViewModel()..setModel('Polo');

    expect(viewModel.canSubmit, isTrue);
  });

  test('canSubmit is true with only a year', () {
    final viewModel = HomeSearchViewModel()..setYear(1996);

    expect(viewModel.canSubmit, isTrue);
  });

  test('canSubmit is false for whitespace-only text', () {
    final viewModel = HomeSearchViewModel()
      ..setBrand('   ')
      ..setModel(' ')
      ..setEngine('\t');

    expect(viewModel.canSubmit, isFalse);
  });

  test('search is a no-op when the form is empty', () async {
    final viewModel = HomeSearchViewModel(delay: (_) => Future.value());
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.search();

    expect(viewModel.isSearching, isFalse);
    expect(notifications, 0);
  });

  test('search toggles isSearching around the injected delay', () async {
    final gate = Completer<void>();
    final viewModel = HomeSearchViewModel(
      delay: (_) => gate.future,
    )..setYear(1996);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    final future = viewModel.search();

    expect(viewModel.isSearching, isTrue);
    expect(notifications, 1);

    gate.complete();
    await future;

    expect(viewModel.isSearching, isFalse);
    expect(notifications, 2);
  });

  test('search ignores a second tap while one is in flight', () async {
    var delayCalls = 0;
    final gate = Completer<void>();
    final viewModel = HomeSearchViewModel(
      delay: (_) {
        delayCalls++;
        return gate.future;
      },
    )..setModel('Polo');

    final first = viewModel.search();
    final second = viewModel.search();

    gate.complete();
    await first;
    await second;

    expect(delayCalls, 1);
  });
}

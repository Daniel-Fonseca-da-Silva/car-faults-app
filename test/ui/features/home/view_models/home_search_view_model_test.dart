import 'dart:async';

import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_search_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.onSearch});

  final Future<LookupSearchResult> Function()? onSearch;
  var searchCalls = 0;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    searchCalls++;
    if (onSearch != null) return onSearch!();
    return LookupSearchSuccess(
      vehicle: LookupDemoDisplay.vehicle,
      issues: LookupDemoDisplay.issues,
    );
  }
}

void _fillRequired(HomeSearchViewModel viewModel) {
  viewModel
    ..setBrand('Volkswagen')
    ..setModel('Polo')
    ..setYear(1996)
    ..setEngine('1.6')
    ..setFuel(FuelOption.petrol);
}

void main() {
  test('canSubmit is false when every field is empty', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository());

    expect(viewModel.canSubmit, isFalse);
  });

  test('canSubmit is false with only a brand', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository())
      ..setBrand('Volkswagen');

    expect(viewModel.canSubmit, isFalse);
  });

  test('canSubmit is false with only a model', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository())
      ..setModel('Polo');

    expect(viewModel.canSubmit, isFalse);
  });

  test('canSubmit is false with only a year', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository())
      ..setYear(1996);

    expect(viewModel.canSubmit, isFalse);
  });

  test('canSubmit is true when required fields are filled', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository());
    _fillRequired(viewModel);

    expect(viewModel.canSubmit, isTrue);
  });

  test('canSubmit is false for whitespace-only text', () {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository())
      ..setBrand('   ')
      ..setModel(' ')
      ..setYear(1996)
      ..setEngine('\t')
      ..setFuel(FuelOption.petrol);

    expect(viewModel.canSubmit, isFalse);
  });

  test('search is a no-op when the form is empty', () async {
    final repository = _FakeLookupRepository();
    final viewModel = HomeSearchViewModel(repository: repository);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.search(locale: AppLocale.pt);

    expect(viewModel.isSearching, isFalse);
    expect(repository.searchCalls, 0);
    expect(notifications, 0);
  });

  test('search toggles isSearching around the repository call', () async {
    final gate = Completer<LookupSearchResult>();
    final viewModel = HomeSearchViewModel(
      repository: _FakeLookupRepository(onSearch: () => gate.future),
    );
    _fillRequired(viewModel);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    final future = viewModel.search(locale: AppLocale.pt);

    expect(viewModel.isSearching, isTrue);
    expect(notifications, 1);

    gate.complete(
      const LookupSearchSuccess(vehicle: LookupDemoDisplay.vehicle, issues: []),
    );
    await future;

    expect(viewModel.isSearching, isFalse);
    expect(viewModel.lastResult, isA<LookupSearchSuccess>());
    expect(notifications, 2);
  });

  test('search ignores a second tap while one is in flight', () async {
    final gate = Completer<LookupSearchResult>();
    final repository = _FakeLookupRepository(onSearch: () => gate.future);
    final viewModel = HomeSearchViewModel(repository: repository);
    _fillRequired(viewModel);

    final first = viewModel.search(locale: AppLocale.pt);
    final second = viewModel.search(locale: AppLocale.pt);

    gate.complete(
      const LookupSearchSuccess(vehicle: LookupDemoDisplay.vehicle, issues: []),
    );
    await first;
    await second;

    expect(repository.searchCalls, 1);
  });
}

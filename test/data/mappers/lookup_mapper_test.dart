import 'package:car_faults_app/data/mappers/lookup_mapper.dart';
import 'package:car_faults_app/domain/models/fix_vote_value.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fuelTypeApiValue', () {
    test('maps every FuelOption to the API fuel-type string', () {
      expect(fuelTypeApiValue(FuelOption.petrol), 'gasoline');
      expect(fuelTypeApiValue(FuelOption.diesel), 'diesel');
      expect(fuelTypeApiValue(FuelOption.electric), 'electric');
      expect(fuelTypeApiValue(FuelOption.lpg), 'gpl');
      expect(fuelTypeApiValue(FuelOption.hybrid), 'hybrid');
    });
  });

  group('fuelOptionFromApiValue', () {
    test('reverses known API values', () {
      expect(fuelOptionFromApiValue('gasoline'), FuelOption.petrol);
      expect(fuelOptionFromApiValue('diesel'), FuelOption.diesel);
      expect(fuelOptionFromApiValue('electric'), FuelOption.electric);
      expect(fuelOptionFromApiValue('gpl'), FuelOption.lpg);
      expect(fuelOptionFromApiValue('hybrid'), FuelOption.hybrid);
    });

    test('returns null for an unrecognized value', () {
      expect(fuelOptionFromApiValue('hydrogen'), isNull);
    });
  });

  group('issueSeverityFromApiValue', () {
    test('parses each IssueSeverity name', () {
      expect(issueSeverityFromApiValue('low'), IssueSeverity.low);
      expect(issueSeverityFromApiValue('medium'), IssueSeverity.medium);
      expect(issueSeverityFromApiValue('high'), IssueSeverity.high);
      expect(issueSeverityFromApiValue('critical'), IssueSeverity.critical);
    });

    test('falls back to low for an unrecognized value', () {
      expect(issueSeverityFromApiValue('extreme'), IssueSeverity.low);
    });
  });

  group('mapLookupResponse', () {
    test('maps vehicle and known issues with fixes and sources', () {
      final mapped = mapLookupResponse({
        'vehicle': {
          'id': 'veh-1',
          'brand': 'Volkswagen',
          'model': 'Polo',
          'name': 'Polo 6N1',
          'yearFrom': 1996,
          'yearTo': 2000,
          'engine': '1.6',
          'doors': 3,
          'fuelType': 'gasoline',
          'techSpecs': {'power_hp': 75},
        },
        'knownIssues': [
          {
            'id': 'issue-1',
            'title': 'Timing belt',
            'description': 'Wear at high mileage',
            'severity': 'high',
            'typicalKm': 90000,
            'sources': ['forum-a', 'forum-b'],
            'fixes': [
              {
                'id': 'fix-1',
                'summary': 'Replace belt kit',
                'steps': '  Step one\n\nStep two  \n',
                'estimatedCostEur': '350.4',
                'likes': 10,
                'dislikes': 1,
              },
            ],
          },
        ],
      });

      expect(mapped.vehicle.id, 'veh-1');
      expect(mapped.vehicle.brand, 'Volkswagen');
      expect(mapped.vehicle.model, 'Polo');
      expect(mapped.vehicle.name, 'Polo 6N1');
      expect(mapped.vehicle.yearFrom, 1996);
      expect(mapped.vehicle.yearTo, 2000);
      expect(mapped.vehicle.engine, '1.6');
      expect(mapped.vehicle.doors, 3);
      expect(mapped.vehicle.fuelType, 'gasoline');
      expect(mapped.vehicle.powerHp, 75);

      expect(mapped.issues, hasLength(1));
      final issue = mapped.issues.single;
      expect(issue.id, 'issue-1');
      expect(issue.title, 'Timing belt');
      expect(issue.severity, IssueSeverity.high);
      expect(issue.typicalKm, 90000);
      expect(issue.sources, ['forum-a', 'forum-b']);
      expect(issue.reviews, isEmpty);

      final fix = issue.fixes.single;
      expect(fix.id, 'fix-1');
      expect(fix.summary, 'Replace belt kit');
      expect(fix.steps, ['Step one', 'Step two']);
      expect(fix.estimatedCostEur, 350);
      expect(fix.likes, 10);
      expect(fix.dislikes, 1);
    });

    test('applies vehicle defaults when optional fields are absent', () {
      final mapped = mapLookupResponse({
        'vehicle': {
          'id': 'veh-2',
          'brand': 'Fiat',
          'model': 'Punto',
          'yearFrom': 2005,
          'engine': '1.2',
        },
        'knownIssues': const [],
      });

      expect(mapped.vehicle.name, '1.2');
      expect(mapped.vehicle.yearTo, 2005);
      expect(mapped.vehicle.doors, 0);
      expect(mapped.vehicle.fuelType, '');
      expect(mapped.vehicle.powerHp, 0);
      expect(mapped.issues, isEmpty);
    });

    test('handles missing sources, empty steps and invalid cost', () {
      final mapped = mapLookupResponse({
        'vehicle': {
          'id': 'veh-3',
          'brand': 'Opel',
          'model': 'Corsa',
          'yearFrom': 2010,
          'yearTo': 2014,
          'engine': '1.4',
          'doors': 5,
          'fuelType': 'diesel',
          'techSpecs': {'power_hp': 90.7},
        },
        'knownIssues': [
          {
            'id': 'issue-2',
            'title': 'Rust',
            'description': 'Rear arches',
            'severity': 'medium',
            'typicalKm': null,
            'fixes': [
              {
                'id': 'fix-2',
                'summary': 'Weld patch',
                'steps': '   \n  ',
                'estimatedCostEur': 'not-a-number',
                'likes': 0,
                'dislikes': 0,
              },
              {
                'id': 'fix-3',
                'summary': 'No cost field',
                'steps': 'Only one step',
                'estimatedCostEur': null,
                'likes': 2,
                'dislikes': 0,
              },
            ],
          },
        ],
      });

      final issue = mapped.issues.single;
      expect(issue.sources, isEmpty);
      expect(issue.fixes[0].steps, ['   \n  ']);
      expect(issue.fixes[0].estimatedCostEur, 0);
      expect(issue.fixes[1].steps, ['Only one step']);
      expect(issue.fixes[1].estimatedCostEur, 0);
      expect(mapped.vehicle.powerHp, 90);
    });
  });

  group('mapKnownIssue', () {
    test('maps a KnownIssueResponseDto body, as embedded in a user vehicle '
        "detail's knownIssues[]", () {
      final issue = mapKnownIssue({
        'id': 'issue-1',
        'title': 'Timing belt',
        'description': 'Wear at high mileage',
        'severity': 'high',
        'typicalKm': 90000,
        'sources': ['forum-a'],
        'fixes': <Map<String, dynamic>>[],
      });

      expect(issue.id, 'issue-1');
      expect(issue.title, 'Timing belt');
      expect(issue.severity, IssueSeverity.high);
      expect(issue.typicalKm, 90000);
      expect(issue.sources, ['forum-a']);
      expect(issue.fixes, isEmpty);
      expect(issue.reviews, isEmpty);
    });
  });

  group('mapFixResponse', () {
    test('maps myVote when present', () {
      final fix = mapFixResponse({
        'id': 'fix-1',
        'summary': 'Replace belt kit',
        'steps': 'Step one\nStep two',
        'estimatedCostEur': '350.40',
        'likes': 10,
        'dislikes': 1,
        'myVote': 'dislike',
      });

      expect(fix.myVote, FixVoteValue.dislike);
    });

    test('maps myVote to null when absent (e.g. embedded in a lookup '
        'response)', () {
      final fix = mapFixResponse({
        'id': 'fix-1',
        'summary': 'Replace belt kit',
        'steps': 'Step one',
        'estimatedCostEur': null,
        'likes': 0,
        'dislikes': 0,
      });

      expect(fix.myVote, isNull);
    });
  });

  group('fixVoteValueFromApiValue', () {
    test('parses each FixVoteValue name', () {
      expect(fixVoteValueFromApiValue('like'), FixVoteValue.like);
      expect(fixVoteValueFromApiValue('dislike'), FixVoteValue.dislike);
    });

    test('returns null for a missing or unrecognized value', () {
      expect(fixVoteValueFromApiValue(null), isNull);
      expect(fixVoteValueFromApiValue('neutral'), isNull);
    });
  });

  group('fixVoteValueApiValue', () {
    test('maps every FixVoteValue to its API string', () {
      expect(fixVoteValueApiValue(FixVoteValue.like), 'like');
      expect(fixVoteValueApiValue(FixVoteValue.dislike), 'dislike');
    });
  });
}

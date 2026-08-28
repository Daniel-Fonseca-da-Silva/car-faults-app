import '../../../domain/models/issue_severity.dart';
import '../../../domain/models/known_issue.dart';
import '../../../domain/models/saved_vehicle.dart';

/// Mocked garage snapshot shown on the garage screen: the user's saved
/// vehicle and its known issues.
///
/// Placeholder data: there is no garage backend in this delivery.
abstract final class GarageDemoDisplay {
  static const vehicles = <SavedVehicle>[
    SavedVehicle(
      id: 'fiat-punto-2001',
      brand: 'Fiat',
      model: 'Punto',
      name: 'Punto',
      yearFrom: 2001,
      yearTo: 2001,
      knownIssuesCount: 3,
    ),
  ];

  static const issues = <KnownIssue>[
    KnownIssue(
      id: 'timing-belt-wear',
      title: 'Timing belt wear and failure',
      description:
          'The timing belt on the 1.2 8v gasoline engine can deteriorate '
          'and break if not replaced at the recommended interval, risking '
          'severe engine damage.',
      severity: IssueSeverity.high,
      sources: ['Fiat workshop manual'],
      fixes: [],
      reviews: [],
    ),
    KnownIssue(
      id: 'ignition-coil-failure',
      title: 'Ignition coil failure',
      description:
          'Ignition coils on the 1.2 8v engine can develop internal cracks, '
          'causing misfires and a loss of power.',
      severity: IssueSeverity.medium,
      sources: ['AutoDoc'],
      fixes: [],
      reviews: [],
    ),
    KnownIssue(
      id: 'fuel-pump-failure',
      title: 'Fuel pump failure',
      description:
          'The electric fuel pump may fail, leading to difficulty '
          'starting, stalling or loss of power while driving.',
      severity: IssueSeverity.medium,
      sources: ['Fiat service bulletin'],
      fixes: [],
      reviews: [],
    ),
  ];
}

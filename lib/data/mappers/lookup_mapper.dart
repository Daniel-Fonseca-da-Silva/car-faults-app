import '../../domain/models/fix_vote_value.dart';
import '../../domain/models/issue_fix.dart';
import '../../domain/models/issue_severity.dart';
import '../../domain/models/known_issue.dart';
import '../../domain/models/lookup_vehicle.dart';
import '../../ui/features/home/home_search_options.dart';

/// `FuelOption` (en-GB naming used by the search form) to `car-faults-api`'s
/// `FuelType` enum value (`vehicle-models/enums/fuel-type.enum.ts`).
const _fuelApiValues = <FuelOption, String>{
  FuelOption.petrol: 'gasoline',
  FuelOption.diesel: 'diesel',
  FuelOption.electric: 'electric',
  FuelOption.lpg: 'gpl',
  FuelOption.hybrid: 'hybrid',
};

String fuelTypeApiValue(FuelOption fuel) => _fuelApiValues[fuel]!;

/// Reverse of [fuelTypeApiValue], for displaying a vehicle's raw API fuel
/// type with a localized label. Returns `null` for an unrecognized value.
FuelOption? fuelOptionFromApiValue(String value) {
  for (final entry in _fuelApiValues.entries) {
    if (entry.value == value) return entry.key;
  }
  return null;
}

/// Parses `car-faults-api`'s `IssueSeverity` enum value
/// (`known-issues/enums/issue-severity.enum.ts`), which matches
/// [IssueSeverity.name] exactly. Falls back to [IssueSeverity.low] for an
/// unrecognized value rather than throwing.
IssueSeverity issueSeverityFromApiValue(String value) {
  return IssueSeverity.values.firstWhere(
    (severity) => severity.name == value,
    orElse: () => IssueSeverity.low,
  );
}

/// Maps a `GET /v1/lookups` JSON body (`LookupResponseDto`) to domain
/// models. Reviews are not part of this response — phase 2 loads them
/// separately — so every [KnownIssue.reviews] is empty.
({LookupVehicle vehicle, List<KnownIssue> issues}) mapLookupResponse(
  Map<String, dynamic> json,
) {
  final vehicleJson = json['vehicle'] as Map<String, dynamic>;
  final issuesJson = json['knownIssues'] as List<dynamic>;

  return (
    vehicle: _mapVehicle(vehicleJson),
    issues: issuesJson
        .map((issue) => _mapKnownIssue(issue as Map<String, dynamic>))
        .toList(),
  );
}

LookupVehicle _mapVehicle(Map<String, dynamic> json) {
  final engine = json['engine'] as String;
  final yearFrom = json['yearFrom'] as int;
  final techSpecs = json['techSpecs'] as Map<String, dynamic>?;

  return LookupVehicle(
    id: json['id'] as String,
    brand: json['brand'] as String,
    model: json['model'] as String,
    name: (json['name'] as String?) ?? engine,
    yearFrom: yearFrom,
    yearTo: (json['yearTo'] as int?) ?? yearFrom,
    engine: engine,
    doors: (json['doors'] as int?) ?? 0,
    fuelType: (json['fuelType'] as String?) ?? '',
    powerHp: (techSpecs?['power_hp'] as num?)?.toInt() ?? 0,
  );
}

KnownIssue _mapKnownIssue(Map<String, dynamic> json) {
  final sourcesJson = json['sources'] as List<dynamic>?;
  final fixesJson = (json['fixes'] as List<dynamic>?) ?? const [];

  return KnownIssue(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    severity: issueSeverityFromApiValue(json['severity'] as String),
    typicalKm: json['typicalKm'] as int?,
    sources:
        sourcesJson?.map((source) => source as String).toList() ?? const [],
    fixes: fixesJson
        .map((fix) => mapFixResponse(fix as Map<String, dynamic>))
        .toList(),
    reviews: const [],
  );
}

/// Maps a `FixResponseDto` JSON body to [IssueFix] — shared by the embedded
/// fixes in `GET /v1/lookups` and the standalone `car-faults-api` fix-vote
/// responses (`myVote` is absent from the former, so it maps to `null`).
IssueFix mapFixResponse(Map<String, dynamic> json) {
  final rawSteps = json['steps'] as String;
  final steps = rawSteps
      .split('\n')
      .map((step) => step.trim())
      .where((step) => step.isNotEmpty)
      .toList();

  return IssueFix(
    id: json['id'] as String,
    summary: json['summary'] as String,
    steps: steps.isEmpty ? [rawSteps] : steps,
    estimatedCostEur: _parseCostEur(json['estimatedCostEur'] as String?),
    likes: json['likes'] as int,
    dislikes: json['dislikes'] as int,
    myVote: fixVoteValueFromApiValue(json['myVote'] as String?),
  );
}

int _parseCostEur(String? value) {
  if (value == null) return 0;
  return double.tryParse(value)?.round() ?? 0;
}

/// Parses `car-faults-api`'s `FixVoteValue` enum value
/// (`fixes/enums/fix-vote-value.enum.ts`), which matches [FixVoteValue.name]
/// exactly. Returns `null` for a missing or unrecognized value.
FixVoteValue? fixVoteValueFromApiValue(String? value) {
  for (final vote in FixVoteValue.values) {
    if (vote.name == value) return vote;
  }
  return null;
}

/// Reverse of [fixVoteValueFromApiValue], for the `POST /v1/fixes/:id/vote`
/// request body.
String fixVoteValueApiValue(FixVoteValue value) => value.name;

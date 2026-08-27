import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../lookup_demo_display.dart';
import 'lookup_spec_tile.dart';

/// Grid of tech spec tiles below [LookupVehicleHero]: years, engine, fuel,
/// doors and power. 2 columns on phones, 5 on tablets.
///
/// Static UI only in this slice: data comes from [LookupDemoDisplay], not a
/// ViewModel or search backend.
class LookupTechSpecs extends StatelessWidget {
  const LookupTechSpecs({super.key});

  static const _tabletBreakpoint = 600.0;
  static const _phoneColumns = 2;
  static const _tabletColumns = 5;
  static const _spacing = 12.0;
  static const _powerUnit = 'hp';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = LookupDemoDisplay.vehicle;

    final tiles = [
      LookupSpecTile(
        icon: Icons.calendar_today,
        label: l10n.lookupSpecYears,
        value: '${vehicle.yearFrom} - ${vehicle.yearTo}',
      ),
      LookupSpecTile(
        icon: Icons.build,
        label: l10n.lookupSpecEngine,
        value: vehicle.engine,
      ),
      LookupSpecTile(
        icon: Icons.local_gas_station,
        label: l10n.lookupSpecFuel,
        value: l10n.homeFuelPetrol,
      ),
      LookupSpecTile(
        icon: Icons.sensor_door,
        label: l10n.lookupSpecDoors,
        value: '${vehicle.doors}',
      ),
      LookupSpecTile(
        icon: Icons.bolt,
        label: l10n.lookupSpecPower,
        value: '${vehicle.powerHp} $_powerUnit',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnCount(constraints.maxWidth);
          final tileWidth = _tileWidth(constraints.maxWidth, columns);

          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
            ],
          );
        },
      ),
    );
  }

  static int _columnCount(double maxWidth) {
    return maxWidth >= _tabletBreakpoint ? _tabletColumns : _phoneColumns;
  }

  static double _tileWidth(double maxWidth, int columns) {
    return (maxWidth - _spacing * (columns - 1)) / columns;
  }
}

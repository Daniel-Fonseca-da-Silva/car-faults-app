import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/profile_snapshot.dart';
import 'profile_stat_card.dart';

/// 2x2 grid of [ProfileStatCard]s built from [ProfileSnapshot.stats].
///
/// Widens to a single row of 4 cards on tablet (>= [_tabletBreakpoint]).
class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key, required this.snapshot});

  final ProfileSnapshot snapshot;

  static const _gap = 12.0;
  static const _tabletBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = snapshot.stats;

    final cards = [
      ProfileStatCard(
        icon: Icons.search,
        value: '${stats.searchesCount}',
        label: l10n.profileStatSearches,
      ),
      ProfileStatCard(
        icon: Icons.menu_book_outlined,
        value: '${stats.defectsConsultedCount}',
        label: l10n.profileStatDefectsConsulted,
      ),
      ProfileStatCard(
        icon: Icons.star_outline,
        value: '${stats.savedVehiclesCount}',
        label: l10n.profileStatSavedVehicles,
      ),
      ProfileStatCard(
        icon: Icons.thumb_up_outlined,
        value: '${stats.votesCount}',
        label: l10n.profileStatVotes,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _tabletBreakpoint) {
          return Row(
            spacing: _gap,
            children: [for (final card in cards) Expanded(child: card)],
          );
        }

        return Column(
          spacing: _gap,
          children: [
            Row(
              spacing: _gap,
              children: [
                Expanded(child: cards[0]),
                Expanded(child: cards[1]),
              ],
            ),
            Row(
              spacing: _gap,
              children: [
                Expanded(child: cards[2]),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

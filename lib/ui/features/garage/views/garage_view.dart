import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../view_models/garage_view_model.dart';

/// Garage ("Garagem") screen: the user's saved vehicles and known issues.
///
/// This slice only wires the screen shell and its view model; the hero,
/// favourites and known issues sections land in later slices.
class GarageView extends StatelessWidget {
  const GarageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<GarageViewModel>();

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [AppFooter(disclaimer: l10n.homeDisclaimer)],
            ),
          );
        },
      ),
    );
  }
}

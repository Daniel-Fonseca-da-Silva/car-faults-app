import '../../../domain/models/issue_fix.dart';
import '../../../domain/models/issue_review.dart';
import '../../../domain/models/issue_severity.dart';
import '../../../domain/models/known_issue.dart';
import '../../../domain/models/lookup_vehicle.dart';
import '../../core/constants/app_assets.dart';

/// Mocked lookup result shown on the results screen, regardless of what was
/// searched.
///
/// Placeholder data: there is no search backend in this delivery.
abstract final class LookupDemoDisplay {
  /// Signed-in demo user, used to flag their own review in the UI.
  static const currentUserId = 'user-ana';
  static const currentUserName = 'Ana Silva';
  static const currentUserInitials = 'AS';

  /// Hero photo for [vehicle]. Kept out of [LookupVehicle] because it is a
  /// UI-layer concern, not domain data.
  static const vehicleImage = AppAssets.citroen2Cv;

  static const vehicle = LookupVehicle(
    id: 'vw-polo-6n1',
    brand: 'Volkswagen',
    model: 'Polo',
    name: 'Polo 6N1',
    yearFrom: 1994,
    yearTo: 1999,
    engine: '1.6',
    doors: 4,
    fuelType: 'Gasoline',
    powerHp: 101,
  );

  static const issues = <KnownIssue>[
    KnownIssue(
      id: 'gearbox-sync',
      title: 'Caixa de câmbio problemática',
      description:
          'A partir dos 120.000 km os sincronizadores da 2ª e 3ª velocidade '
          'desgastam-se, causando engates difíceis e ranger ao trocar de '
          'marchas. O problema agrava-se com uso urbano intenso e óleo de '
          'câmbio fora do prazo.',
      severity: IssueSeverity.high,
      typicalKm: 120000,
      sources: [
        'https://www.auto.pt/forum/polo-cambio-sincronizadores',
        'https://www.recall-info.eu/vw/polo/gearbox-wear',
      ],
      fixes: [
        IssueFix(
          id: 'gearbox-sync-overhaul',
          summary:
              'Substituição dos sincronizadores e revisão completa da caixa',
          steps: [
            'Remover a caixa de câmbio do veículo.',
            'Desmontar e inspecionar todos os sincronizadores e engrenagens.',
            'Substituir os sincronizadores da 2ª e 3ª velocidade desgastados.',
            'Substituir rolamentos e retentores danificados.',
            'Remontar a caixa com óleo novo especificado pelo fabricante.',
            'Instalar a caixa e testar todas as marchas em estrada.',
          ],
          estimatedCostEur: 450,
          likes: 312,
          dislikes: 18,
        ),
        IssueFix(
          id: 'gearbox-oil-change',
          summary: 'Troca do óleo de câmbio como solução temporária',
          steps: [
            'Drenar o óleo de câmbio usado.',
            'Substituir por óleo novo dentro da especificação do fabricante.',
            'Verificar o comportamento dos engates após alguns dias de uso.',
          ],
          estimatedCostEur: 55,
          likes: 87,
          dislikes: 9,
        ),
      ],
      reviews: [
        IssueReview(
          id: 'review-ricardo',
          userId: 'user-ricardo',
          userName: 'Ricardo Moura',
          initials: 'RM',
          rating: 5,
          comment:
              'Informação muito precisa. Exactamente o que aconteceu ao '
              'meu Polo 97.',
          submittedAgo: 'há 2 d',
        ),
        IssueReview(
          id: 'review-fabio',
          userId: 'user-fabio',
          userName: 'Fábio Lopes',
          initials: 'FL',
          rating: 4,
          comment: '',
          submittedAgo: 'há 6 h',
        ),
        IssueReview(
          id: 'review-ana',
          userId: currentUserId,
          userName: currentUserName,
          initials: currentUserInitials,
          rating: 4,
          comment: 'Útil, mas podia ter mais detalhe sobre o modelo de 1996.',
          submittedAgo: 'há 25 min',
        ),
      ],
    ),
    KnownIssue(
      id: 'floor-corrosion',
      title: 'Corrosão na estrutura do assoalho',
      description:
          'Modelos produzidos antes de 1997 apresentam corrosão agressiva '
          'no assoalho e nos longarinos dianteiros, especialmente em regiões '
          'com alto índice de umidade ou uso de sal nas estradas. O problema '
          'avança silenciosamente e pode comprometer a segurança estrutural.',
      severity: IssueSeverity.critical,
      mileageNote: 'Independente da quilometragem — relacionado à idade',
      sources: [
        'https://www.tuvrheinland.com/reports/vw-polo-corrosion',
        'https://forum.classic-vw.com/polo-6n-floorpan-rust',
      ],
      fixes: [
        IssueFix(
          id: 'floor-corrosion-treatment',
          summary: 'Tratamento anticorrosivo profissional e reforço estrutural',
          steps: [
            'Realizar inspeção visual e com espátula em toda a área do '
                'assoalho e caixas de roda.',
            'Remover ferrugem superficial com escova de arame e lixa 80.',
            'Aplicar convertedor de ferrugem (ex: Fertan) e aguardar 24h.',
            'Tratar áreas perfuradas com solda MIG; reforçar com chapa de '
                'aço 1,2 mm se necessário.',
            'Aplicar primer epóxi e tinta betuminosa no interior.',
            'Finalizar com Underbody Seal nas áreas expostas ao asfalto.',
          ],
          estimatedCostEur: 1200,
          likes: 87,
          dislikes: 5,
        ),
      ],
      reviews: [],
    ),
    KnownIssue(
      id: 'cooling-failure',
      title: 'Falha no sistema de arrefecimento',
      description:
          'A partir dos 90.000 km a bomba de água e as mangueiras do '
          'radiador endurecem e começam a apresentar fugas, podendo levar a '
          'sobreaquecimento do motor se não forem substituídas a tempo.',
      severity: IssueSeverity.medium,
      typicalKm: 90000,
      sources: ['https://www.auto.pt/forum/polo-arrefecimento-bomba-agua'],
      fixes: [
        IssueFix(
          id: 'cooling-pump-hoses',
          summary: 'Substituição da bomba de água e mangueiras do radiador',
          steps: [
            'Drenar o líquido de arrefecimento.',
            'Substituir a bomba de água e a correia associada.',
            'Substituir as mangueiras do radiador e abraçadeiras.',
            'Encher o sistema com líquido de arrefecimento novo e purgar o ar.',
          ],
          estimatedCostEur: 180,
          likes: 44,
          dislikes: 3,
        ),
      ],
      reviews: [],
    ),
  ];
}

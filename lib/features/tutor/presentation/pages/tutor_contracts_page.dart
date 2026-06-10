import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/providers.dart';
import '../../../common/presentation/widgets/contract_card.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_ui.dart';

/// Contrats du tuteur — liste partagée (`/common/contracts`), tap → détail.
class TutorContractsPage extends ConsumerWidget {
  const TutorContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final async = ref.watch(contractsProvider);
    final lang = ref.watch(currentUserProvider).asData?.value?.lang ?? 'fr';
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorContracts),
      appBar: TutorAppBar(
        title: tr.contracts.title,
        subtitle: tr.tutor.contracts.subtitle,
      ),
      body: async.when(
        loading: () => const TutorLoading(),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(contractsProvider),
        ),
        data: (contracts) => contracts.isEmpty
            ? SoeEmptyState(
                icon: Icons.article_outlined,
                title: tr.contracts.empty,
                message: tr.contracts.empty,
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(contractsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: contracts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => ContractCard(
                    contract: contracts[i],
                    lang: lang,
                    onTap: () => context.push(
                      RouteNames.contractDetail,
                      extra: contracts[i],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

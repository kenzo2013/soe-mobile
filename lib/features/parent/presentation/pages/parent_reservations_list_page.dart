import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/reservation_summary.dart';
import '../providers.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/recent_reservation_row.dart' show RecentReservationRow;

class ParentReservationsListPage extends ConsumerStatefulWidget {
  const ParentReservationsListPage({super.key});
  @override
  ConsumerState<ParentReservationsListPage> createState() =>
      _ParentReservationsListPageState();
}

class _ParentReservationsListPageState
    extends ConsumerState<ParentReservationsListPage> {
  int _filter = 0;

  List<String> _filters(Translations tr) => [
        tr.parent.reservationsList.filterAll,
        tr.parent.reservationsList.filterPending,
        tr.parent.reservationsList.filterQuoteReceived,
        tr.parent.reservationsList.filterAccepted,
        tr.parent.reservationsList.filterCompleted,
      ];

  bool _match(ReservationSummary r) {
    switch (_filter) {
      case 1:
        return r.status == ReservationStatus.pending;
      case 2:
        return r.status == ReservationStatus.proposedPrice;
      case 3:
        return r.status == ReservationStatus.accepted ||
            r.status == ReservationStatus.active;
      case 4:
        return r.status == ReservationStatus.completed;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final filters = _filters(tr);
    final state = ref.watch(reservationsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(activeRoute: RouteNames.parentReservations),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          tr.parent.reservationsList.title,
          style: const TextStyle(
            color: AppPalette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.push('/parent/reservations/new'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: AppPalette.ink, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final active = _filter == i;
                return InkWell(
                  onTap: () => setState(() => _filter = i),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppPalette.ink : AppPalette.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active ? AppPalette.ink : AppPalette.n300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filters[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppPalette.n700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (f) => ErrorView(
                failure: f,
                onRetry: () => ref
                    .read(reservationsListViewModelProvider.notifier)
                    .refresh(),
              ),
              loaded: (items) {
                final filtered = items.where(_match).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _filter == 0
                            ? tr.parent.reservationsList.emptyAll
                            : tr.parent.reservationsList.emptyCategory,
                        style: const TextStyle(
                          color: AppPalette.n700,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(reservationsListViewModelProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => SoeCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () => context.push(
                          '/parent/reservations/${filtered[i].id}',
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: RecentReservationRow(
                            reservation: filtered[i],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// helper for fcfa (currently unused but keeps import clean)
String _fcfa(int n) => '${NumberFormat.decimalPattern("fr_FR").format(n)} FCFA';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/parent_invitation.dart';
import '../../domain/entities/parent_program.dart';
import '../../domain/entities/parent_review.dart';
import '../../domain/repositories/misc_repositories.dart';

sealed class AsyncListState<T> {
  const AsyncListState();
}

class AsyncListInitial<T> extends AsyncListState<T> {
  const AsyncListInitial();
}

class AsyncListLoading<T> extends AsyncListState<T> {
  const AsyncListLoading();
}

class AsyncListLoaded<T> extends AsyncListState<T> {
  const AsyncListLoaded(this.items);
  final List<T> items;
}

class AsyncListError<T> extends AsyncListState<T> {
  const AsyncListError(this.failure);
  final Failure failure;
}

class _SimpleListVM<T> extends StateNotifier<AsyncListState<T>> {
  _SimpleListVM(this._fetch) : super(AsyncListInitial<T>());
  final Future<Result<List<T>, Failure>> Function() _fetch;

  Future<void> load() async {
    state = AsyncListLoading<T>();
    final r = await _fetch();
    state = switch (r) {
      Ok(:final value) => AsyncListLoaded<T>(value),
      Err(:final failure) => AsyncListError<T>(failure),
    };
  }

  Future<void> refresh() => load();
}

class ReviewsListViewModel extends _SimpleListVM<ParentReview> {
  ReviewsListViewModel(ReviewsRepository r) : super(r.list);
}

class ProgramsListViewModel extends _SimpleListVM<ParentProgram> {
  ProgramsListViewModel(ProgramsRepository r) : super(r.list);
}

class InvitationsListViewModel extends _SimpleListVM<ParentInvitation> {
  InvitationsListViewModel(InvitationsRepository r) : super(r.list);
}

class ContractsListViewModel extends _SimpleListVM<Contract> {
  ContractsListViewModel(ContractsRepository r) : super(r.list);
}

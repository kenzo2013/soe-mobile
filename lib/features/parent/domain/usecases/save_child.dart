import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/child.dart';
import '../repositories/children_repository.dart';

class SaveChild {
  const SaveChild(this._repo);
  final ChildrenRepository _repo;

  Future<Result<Child, Failure>> call({
    String? id,
    required ChildFormParams params,
    File? photo,
  }) =>
      id == null
          ? _repo.create(params, photo: photo)
          : _repo.update(id, params, photo: photo);
}

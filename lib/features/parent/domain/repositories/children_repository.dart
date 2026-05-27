import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/child.dart';

abstract interface class ChildrenRepository {
  Future<Result<List<Child>, Failure>> list();
  Future<Result<Child, Failure>> get(String id);

  /// `photo` optionnel — si fourni, l'API reçoit la requête en
  /// multipart/form-data (CDC §11.6, champ `student[photo]`).
  Future<Result<Child, Failure>> create(
    ChildFormParams params, {
    File? photo,
  });
  Future<Result<Child, Failure>> update(
    String id,
    ChildFormParams params, {
    File? photo,
  });
  Future<Result<void, Failure>> delete(String id);
}

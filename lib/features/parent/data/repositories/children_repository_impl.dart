import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/children_repository.dart';
import '../datasources/children_remote_datasource.dart';
import '../dtos/child_dto.dart';

class ChildrenRepositoryImpl implements ChildrenRepository {
  const ChildrenRepositoryImpl(this._ds);
  final ChildrenRemoteDatasource _ds;

  @override
  Future<Result<List<Child>, Failure>> list() async {
    try {
      final dtos = await _ds.list();
      return Ok(dtos.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<Child, Failure>> get(String id) async {
    try {
      final dto = await _ds.get(id);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<Child, Failure>> create(
    ChildFormParams params, {
    File? photo,
  }) async {
    try {
      final dto = await _ds.create(childParamsToJson(params), photo: photo);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<Child, Failure>> update(
    String id,
    ChildFormParams params, {
    File? photo,
  }) async {
    try {
      final dto =
          await _ds.update(id, childParamsToJson(params), photo: photo);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<void, Failure>> delete(String id) async {
    try {
      await _ds.delete(id);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
}

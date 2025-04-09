import 'dart:io';

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/profile.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class UserRepository {
  /// 유저 프로필을 조회
  Future<Either<Failure, Profile>> getUserProfile();

  // 유저 정보 업데이트
  Future<Either<Failure, void>> updateUserProfile(Profile profile, MultipartFile? image);
}
import 'dart:io';

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/user/profile_remote_data_source.dart';
import 'package:ari/data/models/user/profile_model.dart';
import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/repositories/user/user_repository.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Profile>> getUserProfile() async {
    try {
      final response = await dataSource.getUserProfile();

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(Profile profile, File image) async {
    try {
      await dataSource.updateUserProfile(
        UpdateProfileRequest(
          nickname: profile.nickname,
          bio: profile.bio,
          instagramId: profile.instagram,
          profileImage: image,
        )
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
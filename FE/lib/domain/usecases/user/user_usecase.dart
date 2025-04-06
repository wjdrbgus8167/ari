// 인증 상태를 받을 수 있음음
import 'dart:io';

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/repositories/user/user_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call() => repository.getUserProfile();
}
class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

   Future<Either<Failure, void>> call(Profile profile, File image) => repository.updateUserProfile(profile, image);
}
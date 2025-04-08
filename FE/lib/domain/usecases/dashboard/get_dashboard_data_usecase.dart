import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<Either<Failure, ArtistDashboardData>> call() => repository.getDashboardData();
}
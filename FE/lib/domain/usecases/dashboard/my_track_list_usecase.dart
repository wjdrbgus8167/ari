import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/dashboard/track_stats_model.dart';
import 'package:ari/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetTrackStatsUseCase {
  final DashboardRepository repository;

  GetTrackStatsUseCase(this.repository);

  Future<Either<Failure, TrackStatsList>> call() => repository.getTrackStatsList();
}
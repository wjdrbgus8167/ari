import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/data/models/dashboard/track_stats_model.dart';
import 'package:dartz/dartz.dart';

abstract class DashboardRepository {
  Future<Either<Failure, TrackStatsList>> getTrackStatsList();
  Future<Either<Failure, ArtistDashboardData>> getDashboardData();
}

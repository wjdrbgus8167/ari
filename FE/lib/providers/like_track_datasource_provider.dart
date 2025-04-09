import 'package:ari/data/datasources/like_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';

final likeRemoteDatasourceProvider = Provider<LikeRemoteDatasource>((ref) {
  final dio = ref.read(dioProvider);
  return LikeRemoteDatasource(dio: dio);
});

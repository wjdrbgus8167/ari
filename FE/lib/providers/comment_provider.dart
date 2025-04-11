import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/comment_remote_datasource.dart';
import 'package:ari/providers/global_providers.dart';

final commentRemoteDatasourceProvider = Provider<CommentRemoteDatasource>((
  ref,
) {
  return CommentRemoteDatasource(dio: ref.watch(dioProvider));
});

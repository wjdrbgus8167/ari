// lib/providers/my_channel/notice_comment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/my_channel/notice_comment_remote_datasource.dart';
import '../../data/datasources/my_channel/notice_comment_remote_datasource_impl.dart';
import '../../data/repositories/my_channel/notice_comment_repository_impl.dart';
import '../../domain/repositories/my_channel/notice_comment_repository.dart';
import '../../domain/usecases/auth/auth_usecase.dart';
import '../../domain/usecases/my_channel/notice_comment_usecases.dart';
import '../global_providers.dart';
import '../../providers/auth/auth_providers.dart';

/// 공지사항 댓글 원격 데이터소스 Provider
final noticeCommentRemoteDataSourceProvider =
    Provider<NoticeCommentRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      final getTokensUseCase = ref.watch(getTokensUseCaseProvider);
      return NoticeCommentRemoteDataSourceImpl(
        dio: dio,
        getTokensUseCase: getTokensUseCase,
      );
    });

/// 공지사항 댓글 리포지토리 Provider
final noticeCommentRepositoryProvider = Provider<NoticeCommentRepository>((
  ref,
) {
  final dataSource = ref.watch(noticeCommentRemoteDataSourceProvider);
  return NoticeCommentRepositoryImpl(remoteDataSource: dataSource, ref: ref);
});

/// 공지사항 댓글 목록 조회 유스케이스 Provider
final getNoticeCommentsUseCaseProvider = Provider<GetNoticeCommentsUseCase>((
  ref,
) {
  final repository = ref.watch(noticeCommentRepositoryProvider);
  return GetNoticeCommentsUseCase(repository);
});

/// 공지사항 댓글 등록 유스케이스 Provider
final createNoticeCommentUseCaseProvider = Provider<CreateNoticeCommentUseCase>(
  (ref) {
    final repository = ref.watch(noticeCommentRepositoryProvider);
    return CreateNoticeCommentUseCase(repository);
  },
);

/// 공지사항 댓글 수정 유스케이스 Provider
final updateNoticeCommentUseCaseProvider = Provider<UpdateNoticeCommentUseCase>(
  (ref) {
    final repository = ref.watch(noticeCommentRepositoryProvider);
    return UpdateNoticeCommentUseCase(repository);
  },
);

/// 공지사항 댓글 삭제 유스케이스 Provider
final deleteNoticeCommentUseCaseProvider = Provider<DeleteNoticeCommentUseCase>(
  (ref) {
    final repository = ref.watch(noticeCommentRepositoryProvider);
    return DeleteNoticeCommentUseCase(repository);
  },
);

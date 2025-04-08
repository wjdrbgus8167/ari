package com.ccc.ari.music.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.infrastructure.repository.album.JpaAlbumRepository;
import com.ccc.ari.music.mapper.AlbumMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final JpaAlbumRepository jpaAlbumRepository;

    public AlbumDto getAlbumById(Integer albumId) {
        AlbumEntity entity = jpaAlbumRepository.findById(albumId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return AlbumMapper.toDto(entity);
    }

    public AlbumEntity saveAlbum(AlbumEntity album) {

        AlbumEntity entity =jpaAlbumRepository.save(album);

        return entity;
    }

    public List<AlbumDto> getAllAlbumsByMember(Integer memberId) {
        List<AlbumEntity> list = jpaAlbumRepository.findAllByMember_MemberId(memberId);

        return list.stream()
                .map(AlbumMapper::toDto)
                .collect(Collectors.toList());
    }

    // 최신 앨범 10개 조회
    public List<AlbumEntity> getTop10ByReleasedAt(){
        List<AlbumEntity> list = jpaAlbumRepository.findTop10ByOrderByReleasedAtDesc();

        return list;
    }

    // 장르별 최신 앨범 10개 조회
    public List<AlbumEntity> getTop10NewAlbumsByGenre(Integer genreId) {
        List<AlbumEntity> list = jpaAlbumRepository.findTop10ByGenre_GenreIdOrderByReleasedAtDesc(genreId);
        return list;
    }

    // 장르별 인기 앨범 5개
    public List<AlbumEntity> getTop5AlbumsByEachGenre(Integer genreId) {

        List<AlbumEntity> topAlbums = jpaAlbumRepository.findTop5ByGenre_GenreIdOrderByAlbumLikeCountDesc(genreId);

        return topAlbums;
    }

    //전체 인기 앨범 10개
    public List<AlbumEntity> getTop10Album(){

        return jpaAlbumRepository.findTop10ByOrderByAlbumLikeCountDesc();
    }

    public void increaseAlbumLikeCount(Integer albumId){
        AlbumEntity album = jpaAlbumRepository.findById(albumId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        album.increaseLikeCount();
    }

    public void decreaseAlbumLikeCount(Integer albumId){
        AlbumEntity album = jpaAlbumRepository.findById(albumId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        album.decreaseLikeCount();
    }

    public Optional<List<AlbumEntity>> getAllAlbums(Integer memberId){
        Optional<List<AlbumEntity>> list = jpaAlbumRepository.findListByMember_MemberId(memberId);

        return list;
    }

    // 사용자의 앨범인지 확인
    public boolean existsByIdAndMemberId(Integer albumId, Integer memberId) {

        return jpaAlbumRepository.existsByAlbumIdAndMember_MemberId(albumId,memberId);
    }
}

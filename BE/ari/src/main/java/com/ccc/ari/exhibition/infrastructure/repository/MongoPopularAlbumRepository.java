package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularMusicRepository;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.exhibition.infrastructure.entity.MongoPopularMusic;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MongoPopularAlbumRepository implements PopularMusicRepository<PopularAlbum> {

    private static final String ITEM_TYPE = "ALBUM";
    private final MongoTemplate mongoTemplate;

    @Override
    public void save(PopularAlbum album) {
        List<MongoPopularMusic.MongoPopularEntry> entries = album.getEntries().stream()
                .map(entry -> MongoPopularMusic.MongoPopularEntry.builder()
                        .itemId(entry.getAlbumId())
                        .streamCount(entry.getStreamCount())
                        .build())
                .toList();

        MongoPopularMusic mongoItem = MongoPopularMusic.builder()
                .itemType(ITEM_TYPE)
                .genreId(album.getGenreId())
                .createdAt(album.getCreatedAt())
                .entries(entries)
                .build();

        mongoTemplate.save(mongoItem, "exhibitions");
    }

    @Override
    public Optional<PopularAlbum> findLatestPopularMusic(Integer genreId) {
        Query query = Query.query(Criteria.where("itemType").is(ITEM_TYPE));

        if (genreId == null) {
            query.addCriteria(Criteria.where("genreId").is(null));
        } else {
            query.addCriteria(Criteria.where("genreId").is(genreId));
        }

        query.with(Sort.by(Sort.Direction.DESC, "createdAt"));
        query.limit(1);

        MongoPopularMusic mongoItem = mongoTemplate.findOne(query, MongoPopularMusic.class, "exhibitions");

        return Optional.ofNullable(mongoItem)
                .map(this::toDomainEntity);
    }

    private PopularAlbum toDomainEntity(MongoPopularMusic mongoItem) {
        List<AlbumEntry> entries = mongoItem.getEntries().stream()
                .map(entry -> AlbumEntry.builder()
                        .albumId(entry.getItemId())
                        .streamCount(entry.getStreamCount())
                        .build())
                .toList();

        return PopularAlbum.builder()
                .genreId(mongoItem.getGenreId())
                .entries(entries)
                .createdAt(mongoItem.getCreatedAt())
                .build();
    }
}

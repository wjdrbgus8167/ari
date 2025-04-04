package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularItemRepository;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.exhibition.infrastructure.entity.MongoPopularItem;
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
public class MongoPopularAlbumRepository implements PopularItemRepository<PopularAlbum> {

    private static final String ITEM_TYPE = "ALBUM";
    private final MongoTemplate mongoTemplate;

    @Override
    public void save(PopularAlbum album) {
        List<MongoPopularItem.MongoPopularEntry> entries = album.getEntries().stream()
                .map(entry -> MongoPopularItem.MongoPopularEntry.builder()
                        .itemId(entry.getAlbumId())
                        .count(entry.getStreamCount())
                        .build())
                .toList();

        MongoPopularItem mongoItem = MongoPopularItem.builder()
                .itemType(ITEM_TYPE)
                .genreId(album.getGenreId())
                .createdAt(album.getCreatedAt())
                .entries(entries)
                .build();

        mongoTemplate.save(mongoItem, "exhibitions");
    }

    @Override
    public Optional<PopularAlbum> findLatestPopularItem(Integer genreId) {
        Query query = Query.query(Criteria.where("itemType").is(ITEM_TYPE));

        if (genreId == null) {
            query.addCriteria(Criteria.where("genreId").is(null));
        } else {
            query.addCriteria(Criteria.where("genreId").is(genreId));
        }

        query.with(Sort.by(Sort.Direction.DESC, "createdAt"));
        query.limit(1);

        MongoPopularItem mongoItem = mongoTemplate.findOne(query, MongoPopularItem.class, "exhibitions");

        return Optional.ofNullable(mongoItem)
                .map(this::toDomainEntity);
    }

    private PopularAlbum toDomainEntity(MongoPopularItem mongoItem) {
        List<AlbumEntry> entries = mongoItem.getEntries().stream()
                .map(entry -> AlbumEntry.builder()
                        .albumId(entry.getItemId())
                        .streamCount(entry.getCount())
                        .build())
                .toList();

        return PopularAlbum.builder()
                .genreId(mongoItem.getGenreId())
                .entries(entries)
                .createdAt(mongoItem.getCreatedAt())
                .build();
    }
}

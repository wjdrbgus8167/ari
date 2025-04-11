package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularItemRepository;
import com.ccc.ari.exhibition.domain.entity.PopularPlaylist;
import com.ccc.ari.exhibition.domain.vo.PlaylistEntry;
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
public class MongoPopularPlaylistRepository implements PopularItemRepository<PopularPlaylist> {

    private static final String ITEM_TYPE = "PLAYLIST";
    private final MongoTemplate mongoTemplate;

    @Override
    public void save(PopularPlaylist playlist) {
        List<MongoPopularItem.MongoPopularEntry> entries = playlist.getEntries().stream()
                .map(entry -> MongoPopularItem.MongoPopularEntry.builder()
                        .itemId(entry.getPlaylistId())
                        .count(entry.getShareCount().longValue())
                        .build())
                .toList();

        MongoPopularItem mongoItem = MongoPopularItem.builder()
                .itemType(ITEM_TYPE)
                .genreId(null)
                .createdAt(playlist.getCreatedAt())
                .entries(entries)
                .build();

        mongoTemplate.save(mongoItem, "exhibitions");
    }

    @Override
    public Optional<PopularPlaylist> findLatestPopularItem(Integer genreId) {
        Query query = Query.query(Criteria.where("itemType").is(ITEM_TYPE))
                .with(Sort.by(Sort.Direction.DESC, "createdAt"))
                .limit(1);

        MongoPopularItem mongoItem = mongoTemplate.findOne(query, MongoPopularItem.class, "exhibitions");

        return Optional.ofNullable(mongoItem)
                .map(this::toDomainEntity);
    }

    private PopularPlaylist toDomainEntity(MongoPopularItem mongoItem) {
        List<PlaylistEntry> entries = mongoItem.getEntries().stream()
                .map(entry -> PlaylistEntry.builder()
                        .playlistId(entry.getItemId())
                        .shareCount(entry.getCount().intValue())
                        .build())
                .toList();

        return PopularPlaylist.builder()
                .entries(entries)
                .createdAt(mongoItem.getCreatedAt())
                .build();
    }
}

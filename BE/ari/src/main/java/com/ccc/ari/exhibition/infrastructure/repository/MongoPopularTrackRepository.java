package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularMusicRepository;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import com.ccc.ari.exhibition.domain.vo.TrackEntry;
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
public class MongoPopularTrackRepository implements PopularMusicRepository<PopularTrack> {

    private static final String ITEM_TYPE = "TRACK";
    private final MongoTemplate mongoTemplate;

    @Override
    public void save(PopularTrack track) {
        List<MongoPopularMusic.MongoPopularEntry> entries = track.getEntries().stream()
                .map(entry -> MongoPopularMusic.MongoPopularEntry.builder()
                        .itemId(entry.getTrackId())
                        .streamCount(entry.getStreamCount())
                        .build())
                .toList();

        MongoPopularMusic mongoItem = MongoPopularMusic.builder()
                .itemType(ITEM_TYPE)
                .genreId(track.getGenreId())
                .createdAt(track.getCreatedAt())
                .entries(entries)
                .build();

        mongoTemplate.save(mongoItem, "exhibitions");
    }

    @Override
    public Optional<PopularTrack> findLatestPopularMusic(Integer genreId) {
        Query query = Query.query(Criteria.where("itemType").is(ITEM_TYPE));

        if (genreId == null) {
            query.addCriteria(Criteria.where("genreId").is(null));
        } else {
            query.addCriteria(Criteria.where("genreId").is(genreId));
        }

        query.with(Sort.by(Sort.Direction.DESC, "createdAt")).limit(1);

        MongoPopularMusic mongoItem = mongoTemplate.findOne(query, MongoPopularMusic.class, "exhibitions");

        return Optional.ofNullable(mongoItem)
                .map(this::toDomainEntity);
    }

//    @Override
//    public Optional<PopularTrack> findLatestAll() {
//        return findLatestByGenreId(null);
//    }
//
//    @Override
//    public Optional<PopularTrack> findLatestByGenreId(Integer genreId) {
//        Query query = Query.query(Criteria.where("itemType").is(ITEM_TYPE));
//
//        if (genreId != null) {
//            query.addCriteria(Criteria.where("genreId").is(genreId));
//        } else {
//
//        }
//
//        query.with(Sort.by(Sort.Direction.DESC, "createdAt")).limit(1);
//
//        MongoPopularItem mongoItem = mongoTemplate.findOne(query, MongoPopularItem.class, "exhibitions");
//
//        return Optional.ofNullable(mongoItem)
//                .map(this::toDomainEntity);
//    }

    private PopularTrack toDomainEntity(MongoPopularMusic mongoItem) {
        List<TrackEntry> entries = mongoItem.getEntries().stream()
                .map(entry -> TrackEntry.builder()
                        .trackId(entry.getItemId())
                        .streamCount(entry.getStreamCount())
                        .build())
                .toList();

        return PopularTrack.builder()
                .genreId(mongoItem.getGenreId())
                .entries(entries)
                .createdAt(mongoItem.getCreatedAt())
                .build();
    }
}

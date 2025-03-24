package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.application.fantalk.repository.FantalkRepository;
import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class FantalkRepositoryImpl implements FantalkRepository {

    @Override
    public Fantalk saveFantalk(Fantalk fantalk) {
        return null;
    };
}

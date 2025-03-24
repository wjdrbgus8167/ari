package com.ccc.ari.member.infrastructure;

import com.ccc.ari.member.domain.member.MemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface JpaMemberRepository  extends JpaRepository<MemberEntity, Integer> {
    Optional<MemberEntity> findByEmail(String email);
    Optional<MemberEntity> findByMemberId(Integer memberId);
}

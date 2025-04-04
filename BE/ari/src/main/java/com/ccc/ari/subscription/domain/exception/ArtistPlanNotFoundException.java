package com.ccc.ari.subscription.domain.exception;

public class ArtistPlanNotFoundException extends SubscriptionException {

    public ArtistPlanNotFoundException(Integer artistId) {
        super(ExceptionCode.ARTIST_PLAN_NOT_FOUND,
                String.format("아티스트(ID: %d)의 구독 플랜이 존재하지 않습니다!!", artistId));
    }
}

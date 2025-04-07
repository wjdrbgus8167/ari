package com.ccc.ari.subscription.domain.exception;

public class ArtistSubscriptionNotFoundException extends SubscriptionException {
    
    private final Integer artistId;

    public ArtistSubscriptionNotFoundException(Integer artistId) {
        super(ExceptionCode.REGULAR_SUBSCRIPTION_NOT_FOUND,
                String.format("사용자의 아티스트(ID: %d) 구독이 존재하지 않습니다!!", artistId));
        this.artistId = artistId;
    }
}

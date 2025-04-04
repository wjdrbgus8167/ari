package com.ccc.ari.global.composition.response.artist;

import lombok.Builder;
import lombok.Getter;

@Getter
public class GetChannelInfoResponse {

    private Integer fantalkChannelId;
    private String memberName;
    private String profileImageUrl;
    private Integer subscriberCount;
    private Boolean followedYn;

    @Builder
    public GetChannelInfoResponse(Integer fantalkChannelId, String memberName, String profileImageUrl,
                                  Integer subscriberCount, Boolean followedYn) {

        this.fantalkChannelId = fantalkChannelId;
        this.memberName = memberName;
        this.profileImageUrl = profileImageUrl;
        this.subscriberCount = subscriberCount;
        this.followedYn = followedYn;
    }
}

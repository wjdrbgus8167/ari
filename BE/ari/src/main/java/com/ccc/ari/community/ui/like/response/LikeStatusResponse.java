package com.ccc.ari.community.ui.like.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LikeStatusResponse {

    private final Boolean liked;
}

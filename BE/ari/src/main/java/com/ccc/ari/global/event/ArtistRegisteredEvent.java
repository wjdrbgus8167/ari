package com.ccc.ari.global.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ArtistRegisteredEvent {

    private final Integer artistId;
    private final String address;
}

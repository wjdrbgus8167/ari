package com.ccc.ari.playlist.domain.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ValidateDuplicateTrackService {

    public void validateDuplicateTracks(List<Integer> trackIds) {
        Set<Integer> uniqueTrackIds = new HashSet<>();

        for (Integer trackId : trackIds) {
            if (!uniqueTrackIds.add(trackId)) {
                // 이미 존재하는 ID를 다시 add하면 false를 반환함 → 중복 감지됨
                throw new ApiException(ErrorCode.PLAYLIST_DUPLICATE_TRACK_SELECTED);
            }
        }
    }

}

package com.ccc.ari.music.application.command;

import com.ccc.ari.global.security.MemberUserDetails;
import lombok.Builder;
import lombok.Getter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
public class UploadAlbumCommand {
    private final String genreName;
    private final String albumTitle;
    private final String description;
    private final MultipartFile coverImage;
    private final List<UploadTrackCommand> tracks;
    private final Integer memberId;

    @Builder
    public UploadAlbumCommand(String genreName, String albumTitle, String description,
                              MultipartFile coverImage, List<UploadTrackCommand> tracks,Integer memberId) {
        this.genreName = genreName;
        this.albumTitle = albumTitle;
        this.description = description;
        this.coverImage = coverImage;
        this.tracks = tracks;
        this.memberId = memberId;
    }

    @Getter
    public static class UploadTrackCommand {
        private final Integer trackNumber;
        private final String trackTitle;
        private final String composer;
        private final String lyricist;
        private final String lyrics;
        private final MultipartFile trackFile;

        @Builder
        public UploadTrackCommand(Integer trackNumber, String trackTitle, String composer,
                                  String lyricist, String lyrics, MultipartFile trackFile) {
            this.trackNumber = trackNumber;
            this.trackTitle = trackTitle;
            this.composer = composer;
            this.lyricist = lyricist;
            this.lyrics = lyrics;
            this.trackFile = trackFile;
        }
    }
}

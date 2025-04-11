package com.ccc.ari.music.ui.request;

import com.ccc.ari.music.application.command.UploadAlbumCommand;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.IntStream;

@Getter
@NoArgsConstructor
public class UploadAlbumRequest {

    private String genreName;
    private String albumTitle;
    private String description;
    private List<UploadTrackRequest> tracks;

    @Builder
    public UploadAlbumRequest(String genreName, String albumTitle, String description, List<UploadTrackRequest> tracks) {
        this.genreName = genreName;
        this.albumTitle = albumTitle;
        this.description = description;
        this.tracks = tracks;
    }

    /**
     * Request → Command 변환 (coverImage + trackFiles 추가)
     */
    public UploadAlbumCommand toCommand(MultipartFile coverImage, List<MultipartFile> trackFiles,Integer memberId) {
        List<UploadAlbumCommand.UploadTrackCommand> trackCommands = IntStream.range(0, this.tracks.size())
                .mapToObj(i -> this.tracks.get(i).toCommand(trackFiles.get(i)))
                .toList();

        return UploadAlbumCommand.builder()
                .genreName(this.genreName)
                .albumTitle(this.albumTitle)
                .description(this.description)
                .coverImage(coverImage)
                .tracks(trackCommands)
                .memberId(memberId)
                .build();
    }

    @Getter
    @NoArgsConstructor
    public static class UploadTrackRequest {
        private Integer trackNumber;
        private String trackTitle;
        private String composer;
        private String lyricist;
        private String lyrics;

        @Builder
        public UploadTrackRequest(Integer trackNumber, String trackTitle, String composer, String lyricist, String lyrics) {
            this.trackNumber = trackNumber;
            this.trackTitle = trackTitle;
            this.composer = composer;
            this.lyricist = lyricist;
            this.lyrics = lyrics;
        }

        /**
         * TrackRequest → TrackCommand 변환
         */
        public UploadAlbumCommand.UploadTrackCommand toCommand(MultipartFile trackFile) {
            return UploadAlbumCommand.UploadTrackCommand.builder()
                    .trackNumber(this.trackNumber)
                    .trackTitle(this.trackTitle)
                    .composer(this.composer)
                    .lyricist(this.lyricist)
                    .lyrics(this.lyrics)
                    .trackFile(trackFile)
                    .build();
        }
    }
}

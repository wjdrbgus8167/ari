package com.ccc.ari.playlist.ui;


import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.*;
import com.ccc.ari.playlist.application.serviceImpl.PlaylistServiceImpl;
import com.ccc.ari.playlist.ui.request.AddTrackRequest;
import com.ccc.ari.playlist.ui.request.CreatePlaylistRequest;
import com.ccc.ari.playlist.ui.request.SharePlaylistRequest;
import com.ccc.ari.playlist.ui.response.CreatePlaylistResponse;
import com.ccc.ari.playlist.ui.response.GetPlayListResponse;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class PlaylistController {

    private final PlaylistServiceImpl playlistService;

    // 플레이리스트 생성
    @PostMapping
    public ApiUtils.ApiResponse<CreatePlaylistResponse> createPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails,
            @RequestBody CreatePlaylistRequest request
    ){
        // 플레이리스트 제목과 함께 사용자의 memberId로 생성
        CreatePlaylistCommand command = request.requestToCommand(request.getPlaylistTitle(),memberUserDetails.getMemberId());

        CreatePlaylistResponse response =playlistService.createPlaylist(command);

        // 플레이리스트 제목과 플레이리스트 id return
        return ApiUtils.success(response);
    }

    // 플레이리스트 트랙 추가
    @PostMapping("/{playlistId}/tracks")
    public ApiUtils.ApiResponse<?> addTrack(
           @PathVariable Integer playlistId,
           @RequestBody AddTrackRequest request
    ) {
        //플레이리스트 추가. 여러 개의 플레이리스트를 한 번에 추가하는 경우가 있어 Request는 List 형식
        AddTrackCommand command = request.toCommand(playlistId);
        playlistService.addTrack(command);

        return ApiUtils.success("플레이리스트 트랙 추가");
    }

    // TODO: 아직 플레이리스트 조회 후 관리에 대한 부분을 정하지 않아 추후 프론트와 협의 후 업데이트 예정
    // 플레이리스트 트랙 삭제
    @DeleteMapping("/{playlistId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<?> deleteTrack(
            @PathVariable Integer playlistId,
            @PathVariable Integer trackId
    ) {


        return ApiUtils.success("플레이리스트 트랙 삭제");
    }

    // 플레이리스트 삭제
    @DeleteMapping("/{playlistId}")
    public ApiUtils.ApiResponse<?> deletePlaylist(
            @PathVariable Integer playlistId,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {

        DeletePlaylistCommand command = DeletePlaylistCommand.builder()
                .playlistId(playlistId)
                .memberId(memberUserDetails.getMemberId())
                .build();

       playlistService.deletePlaylist(command);

        return ApiUtils.success("플레이리스트가 삭제되었습니다.");
    }
    // 플레이리스트 목록 조회(본인)
    @GetMapping
    public ApiUtils.ApiResponse<GetPlayListResponse> getPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        // 사용자는 본인이 만든 플레이리스트와 퍼온 플레이리스트가 존재.
        // 자신의 플레이리스트 전체를 조회하여 플레이리스트 제목과 id, 플레이리스트에 담긴 곡 개수를 return
        GetPlaylistCommand command = GetPlaylistCommand.builder()
                                                    .memberId(memberUserDetails.getMemberId())
                                                    .build();
        GetPlayListResponse response = playlistService.getPlaylist(command);

        return ApiUtils.success(response);
    }

    // 플레이리스트 상세 조회
    @GetMapping("/{playlistId}")
    public ApiUtils.ApiResponse<GetPlaylistDetailResponse> getPlaylistDetail(
            @PathVariable Integer playlistId
    ) {
        // 플레이리스트에 담긴 트랙(곡)들의 정보를 return
        GetPlaylistDetailCommand command = GetPlaylistDetailCommand.builder()
                                    .playlistId(playlistId).build();

        GetPlaylistDetailResponse response = playlistService.getPlaylistDetail(command);

        return ApiUtils.success(response);
    }

    // 플레이리스트 퍼가기
    @PostMapping("/share")
    public ApiUtils.ApiResponse<?> sharePlaylist(
            @RequestBody SharePlaylistRequest request,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        // 공개된 플레이리스트에 한해서 사용자가 플레이리스트를 퍼올 수 있음.
        // SharedPlaylist 테이블에 저장됨.
       SharePlaylistCommand command = request.requestToCommand(memberUserDetails.getMemberId());

       playlistService.sharePlaylist(command);

        return ApiUtils.success("음원을 공유했습니다.");
    }

    // 플레이리스트 공개로 전환히기
    @PutMapping("/{playlistId}/publiced")
    public ApiUtils.ApiResponse<?> publicPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails,
            @PathVariable Integer playlistId
    ) {
        // 기본적으로 플레이리스트를 생성하면 비공개(false)로 되어 있음.
        // 자신의 플레이리스트를 공개로 전환.
        // 추후 플레이리스트를 다시 비공개로 전환하는 api 생성 예정.
        PublicPlaylistCommand command = PublicPlaylistCommand.builder()
                .memberId(memberUserDetails.getMemberId())
                .playlistId(playlistId)
                .build();

        playlistService.publicPlaylist(command);

        return ApiUtils.success("공개 상태로 전환되었습니다.");
    }

    // 비공개 처리
    // 공개된 플레이 리스트 목록
}

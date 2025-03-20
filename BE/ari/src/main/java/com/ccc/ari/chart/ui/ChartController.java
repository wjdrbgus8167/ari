package com.ccc.ari.chart.ui;

import com.ccc.ari.chart.application.ChartService;
import com.ccc.ari.chart.application.dto.ChartResponseDto;
import com.ccc.ari.chart.ui.response.ChartEntryResponse;
import com.ccc.ari.chart.ui.response.ChartResponse;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/charts")
@RequiredArgsConstructor
public class ChartController {

    private final ChartService chartService;

    @GetMapping
    public ApiUtils.ApiResponse<ChartResponse> getLatestChart() {
        ChartResponseDto dto = chartService.getLatestChart();
        ChartResponse response = convertToResponse(dto);
        return ApiUtils.success(response);
    }

    /**
     * 애플리케이션 DTO를 UI 응답 객체로 변환합니다.
     */
    private ChartResponse convertToResponse(ChartResponseDto dto) {
        List<ChartEntryResponse> entryResponses = dto.getEntries().stream()
                .map(entry -> ChartEntryResponse.builder()
                        .trackId(entry.getTrackId())
                        .trackTitle(entry.getTrackTitle())
                        .rank(entry.getRank())
                        // 실제 구현에서는 아티스트와 커버 이미지 정보를 어떻게 가져올지 결정 필요
                        .artist("Unknown Artist") // 임시 값
                        .coverImageUrl("") // 임시 빈 값
                        .build())
                .toList();

        return ChartResponse.builder()
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .charts(entryResponses)
                .build();
    }
}

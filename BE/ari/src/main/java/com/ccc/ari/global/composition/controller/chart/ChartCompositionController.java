package com.ccc.ari.global.composition.controller.chart;

import com.ccc.ari.global.composition.response.chart.ChartResponse;
import com.ccc.ari.global.composition.service.chart.ChartService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/charts")
@RequiredArgsConstructor
public class ChartCompositionController {

    private final ChartService chartService;

    @GetMapping
    public ApiUtils.ApiResponse<ChartResponse> getAllChart() {
        ChartResponse response = chartService.getAllChart();
        return ApiUtils.success(response);
    }

    @GetMapping("/genres/{genreId}")
    public ApiUtils.ApiResponse<ChartResponse> getGenreChart(@PathVariable Integer genreId) {
        ChartResponse response = chartService.getGenreChart(genreId);
        return ApiUtils.success(response);
    }
}

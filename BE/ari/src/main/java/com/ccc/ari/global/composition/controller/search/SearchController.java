package com.ccc.ari.global.composition.controller.search;

import com.ccc.ari.global.composition.response.search.SearchResponse;
import com.ccc.ari.global.composition.service.search.SearchService;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping
    public ApiUtils.ApiResponse<SearchResponse> search(@RequestParam("q") String query) {
        if (query == null || query.trim().isEmpty()) {
            throw new ApiException(ErrorCode.INVALID_INPUT_VALUE);
        }

        SearchResponse response = searchService.search(query);
        return ApiUtils.success(response);
    }
}

package com.ccc.ari.global.error;

import com.ccc.ari.global.util.ApiUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ApiUtils.ApiResponse> handleApiException(ApiException ex, WebRequest request) {

        return ResponseEntity
                .status(ex.getErrorCode().getStatus())
                .body(ApiUtils.error(ex.getErrorCode()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiUtils.ApiResponse> handleMethodArgumentNotValidException(MethodArgumentNotValidException ex){

        FieldError error = (FieldError) ex.getBindingResult().getAllErrors().stream().findFirst().orElse(null);
        ErrorCode errorCode = getErrorCodeFromError(error);
        return ResponseEntity
                .status(errorCode.getStatus())
                .body(ApiUtils.error(errorCode));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiUtils.ApiResponse> handleRuntimeException(RuntimeException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        return ResponseEntity
                .status(status)
                .body(ApiUtils.error(status.name(), ex, status));
    }


    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiUtils.ApiResponse> unknownServerError(Exception ex, WebRequest request) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        return ResponseEntity
                .status(status)
                .body(ApiUtils.error(status.name(), ex, status));
    }

    private ErrorCode getErrorCodeFromError(FieldError error) {
        if (error == null || error.getDefaultMessage() == null) {
            return ErrorCode.INVALID_INPUT_PARAMETER;
        }

        try {
            return ErrorCode.valueOf(error.getDefaultMessage());
        } catch (IllegalArgumentException e) {
            return ErrorCode.INVALID_INPUT_PARAMETER;
        }
    }
}

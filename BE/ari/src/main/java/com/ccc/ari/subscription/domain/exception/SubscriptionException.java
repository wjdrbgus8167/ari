package com.ccc.ari.subscription.domain.exception;

public abstract class SubscriptionException extends RuntimeException {

    private final ExceptionCode code;

    protected SubscriptionException(ExceptionCode code, String message) {
        super(message);
        this.code = code;
    }

    public enum ExceptionCode {
        SUBSCRIPTION_NOT_FOUND("SUB_001"),
        SUBSCRIPTION_NOT_ACTIVE("SUB_002");

        private final String code;

        ExceptionCode(String code) {
            this.code = code;
        }

        public String getCode() {
            return code;
        }
    }
}
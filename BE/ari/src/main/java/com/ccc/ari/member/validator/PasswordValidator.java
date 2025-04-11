package com.ccc.ari.member.validator;

import com.ccc.ari.global.error.ErrorCode;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class PasswordValidator implements ConstraintValidator<ValidPassword, String> {

    private int min;
    private int max;

    @Override
    public void initialize(ValidPassword constraintAnnotation) {
        this.min = constraintAnnotation.min();
        this.max = constraintAnnotation.max();
    }
    @Override
    public boolean isValid(String s, ConstraintValidatorContext context) {
        context.disableDefaultConstraintViolation(); // 기본 메시지 비활성화

        // 비밀번호 없음
        if (s == null || s.trim().isEmpty()) {
            context.buildConstraintViolationWithTemplate(ErrorCode.PASSWORD_REQUIRED.name())
                    .addConstraintViolation();
            return false;
        }

        // 비밀번호 길이 부족
        if (s.length() < min) {
            context.buildConstraintViolationWithTemplate(ErrorCode.PASSWORD_TOO_SHORT.name())
                    .addConstraintViolation();
            return false;
        }

        // 비밀번호 길이 초과
        if (s.length() > max) {
            context.buildConstraintViolationWithTemplate(ErrorCode.PASSWORD_TOO_LONG.name())
                    .addConstraintViolation();
            return false;
        }

        return true;
    }
}

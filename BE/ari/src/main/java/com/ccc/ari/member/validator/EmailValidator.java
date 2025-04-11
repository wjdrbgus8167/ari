package com.ccc.ari.member.validator;

import com.ccc.ari.global.error.ErrorCode;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.regex.Pattern;

public class EmailValidator implements ConstraintValidator<ValidEmail, String> {

    private Pattern emailPattern;
    private int max;
    @Override
    public void initialize(ValidEmail constraintAnnotation) {
        this.emailPattern = Pattern.compile(constraintAnnotation.pattern());
        this.max = constraintAnnotation.max();
    }


    @Override
    public boolean isValid(String s, ConstraintValidatorContext context) {
        context.disableDefaultConstraintViolation();

        // 이메일 없음
        if (s == null || s.trim().isEmpty()) {
            context.buildConstraintViolationWithTemplate(ErrorCode.EMAIL_REQUIRED.name())
                    .addConstraintViolation();
            return false;
        }

        // 이메일 길이 초과
        if (s.length() > max) {
            context.buildConstraintViolationWithTemplate(ErrorCode.EMAIL_TOO_LONG.name())
                    .addConstraintViolation();
            return false;
        }

        // 이메일 형식 확인
        if (!emailPattern.matcher(s).matches()) {
            context.buildConstraintViolationWithTemplate(ErrorCode.INVALID_EMAIL_FORMAT.name())
                    .addConstraintViolation();
            return false;
        }

        return true;
    }
}
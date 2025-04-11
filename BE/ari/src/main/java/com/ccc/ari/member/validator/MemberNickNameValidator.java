package com.ccc.ari.member.validator;

import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.validator.BaseNameValidator;

public class MemberNickNameValidator extends BaseNameValidator<ValidMemberNickName> {

    @Override
    protected void setUp(ValidMemberNickName constraintAnnotation) {
        this.max = constraintAnnotation.max();
        this.requiredErrorCode = ErrorCode.MEMBER_NICKNAME_REQUIRED;
        this.tooLongErrorCode = ErrorCode.MEMBER_NICKNAME_TOO_LONG;
    }
}

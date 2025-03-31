package com.ccc.ari.member.ui.reuquest;

import com.ccc.ari.member.validator.ValidEmail;
import com.ccc.ari.member.validator.ValidPassword;
import lombok.Getter;

@Getter
public class MemberLoginRequest {

    @ValidEmail
    String email;

    @ValidPassword
    String password;
}

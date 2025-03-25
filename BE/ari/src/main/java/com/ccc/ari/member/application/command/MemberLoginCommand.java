package com.ccc.ari.member.application.command;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberLoginCommand {
    private final String email;
    private final String password;
}

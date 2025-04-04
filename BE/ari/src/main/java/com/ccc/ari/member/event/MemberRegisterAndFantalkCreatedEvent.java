package com.ccc.ari.member.event;

import com.ccc.ari.event.common.Event;
import lombok.Builder;

public record MemberRegisterAndFantalkCreatedEvent(Integer memberId) implements Event {

    @Builder
    public MemberRegisterAndFantalkCreatedEvent{

    }
}

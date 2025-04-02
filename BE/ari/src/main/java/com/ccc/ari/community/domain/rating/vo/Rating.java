package com.ccc.ari.community.domain.rating.vo;

import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class Rating {
    BigDecimal value;

    public Rating(BigDecimal value) {
        if (value.compareTo(BigDecimal.valueOf(0.5)) < 0 || value.compareTo(BigDecimal.valueOf(5.0)) > 0
                || value.remainder(BigDecimal.valueOf(0.5)).compareTo(BigDecimal.ZERO) != 0) {
            throw new IllegalArgumentException("등록할 수 없는 평점 단위입니다. 0.5 단위로 등록해주세요");
        }
        this.value = value.setScale(1);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Rating other)) return false;
        return this.value.compareTo(other.value) == 0;
    }

    @Override
    public int hashCode() {
        return value.stripTrailingZeros().hashCode();
    }
}

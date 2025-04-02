package com.ccc.ari.subscription.util;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;

public class DecimalConverter {

    public static BigDecimal fromSolidityDecimal(BigInteger solidityValue) {
        return fromSolidityDecimal(solidityValue, 18);
    }

    // 특정 decimal 값을 사용하는 경우
    public static BigDecimal fromSolidityDecimal(BigInteger solidityValue, int decimals) {
        BigDecimal value = new BigDecimal(solidityValue);
        BigDecimal divisor = BigDecimal.TEN.pow(decimals);
        return value.divide(divisor, decimals, RoundingMode.HALF_UP);
    }
}

package com.ccc.ari.aggregation.util;

public class ByteConverter {

    // StreamingAggregationContract의 bytes32 타입으로 변환을 위해 설정
    // TODO: 메인넷 배포 시에는 bytes32가 아니라 bytes4를 사용해도 충분할 것 같습니다.
    private static final int BYTE_LENGTH = 32;

    /**
     * Integer를 32바이트 배열로 변환
     * @param value 변환할 정수값
     * @return 32바이트 배열
     */
    public static byte[] intTo32Bytes(int value) {
        byte[] result = new byte[BYTE_LENGTH];
        // 마지막 4바이트에 정수값을 저장 (나머지는 0으로 패딩)
        result[BYTE_LENGTH - 4] = (byte)(value >> 24);
        result[BYTE_LENGTH - 3] = (byte)(value >> 16);
        result[BYTE_LENGTH - 2] = (byte)(value >> 8);
        result[BYTE_LENGTH - 1] = (byte)value;
        return result;
    }

    /**
     * 32바이트 배열을 Integer로 변환
     * @param bytes 변환할 32바이트 배열
     * @return 변환된 정수값
     * @throws IllegalArgumentException 배열 길이가 32가 아닐 경우
     */
    public static int bytes32ToInt(byte[] bytes) {
        if (bytes.length != BYTE_LENGTH) {
            throw new IllegalArgumentException("배열은 정확히 32바이트여야 합니다");
        }
        return  ((bytes[BYTE_LENGTH - 4] & 0xFF) << 24) |
                ((bytes[BYTE_LENGTH - 3] & 0xFF) << 16) |
                ((bytes[BYTE_LENGTH - 2] & 0xFF) << 8)  |
                ((bytes[BYTE_LENGTH - 1] & 0xFF));
    }
}

package utils;

public class MD5 {

    private static MD5 instance = new MD5();

    private static final int A = 0x67452301;
    private static final int B = 0xefcdab89;
    private static final int C = 0x98badcfe;
    private static final int D = 0x10325476;
    private final int[] SHIFT = {
            7, 12, 17, 22,
            5,  9, 14, 20,
            4, 11, 16, 23,
            6, 10, 15, 21 };

    private final int[] CONSTS = new int[64];

//    private final long[] CONSTS = {
//            0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
//            0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
//            0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
//            0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
//            0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
//            0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
//            0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
//            0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
//            0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
//            0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
//            0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
//            0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
//            0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
//            0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
//            0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
//            0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391 };
    private MD5() {
        for (int i = 0; i < 64; i++) {
            CONSTS[i] = (int)(long)((1L << 32) * Math.abs(Math.sin(i + 1)));
        }
    }

    private byte[] compute(byte[] msg) {

        int originalLengthBytes = msg.length;
        int blocks = ((originalLengthBytes + 8) >>> 6) + 1;
        int finalLength = blocks << 6;

        byte[] padding = new byte[finalLength - originalLengthBytes];
        padding[0] = (byte)0x80;
        long originalLengthBits = (long)originalLengthBytes << 3;
        for (int i = 0; i < 8; i++) {
            padding[padding.length - 8 + i] = (byte)originalLengthBits;
            originalLengthBits >>>= 8;
        }

        int a = A, b = B, c = C, d = D;
        int[] buf = new int[16];
        for (int i = 0; i < blocks; i++) {

            int index = i << 6;
            for (int j = 0; j < 64; j++, index++) {
                buf[j >>> 2] = ((int)((index < originalLengthBytes) ? msg[index] :
                        padding[index - originalLengthBytes]) << 24) | (buf[j >>> 2] >>> 8);
            }

            int a0 = a, b0 = b, c0 = c, d0 = d;
            for (int j = 0; j < 64; j++) {
                int div16 = j >>> 4;
                int f = 0;
                int bufIndex = j;
                switch (div16) {
                    case 0:
                        f = (b & c) | (~b & d);
                        break;
                    case 1:
                        f = (b & d) | (c & ~d);
                        bufIndex = (bufIndex * 5 + 1) & 0x0F;
                        break;
                    case 2:
                        f = b ^ c ^ d;
                        bufIndex = (bufIndex * 3 + 5) & 0x0F;
                        break;
                    case 3:
                        f = c ^ (b | ~d);
                        bufIndex = (bufIndex * 7) & 0x0F;
                        break;
                }

                int tmp = b + Integer.rotateLeft(a + f + buf[bufIndex] + CONSTS[j], SHIFT[(div16 << 2) | (j & 3)]);
                a = d;
                d = c;
                c = b;
                b = tmp;
            }

            a += a0;
            b += b0;
            c += c0;
            d += d0;
        }

        byte[] md5 = new byte[16];
        int count = 0;
        for (int i = 0; i < 4; i++) {
            int n = (i == 0) ? a : ((i == 1) ? b : ((i == 2) ? c : d));
            for (int j = 0; j < 4; j++) {
                md5[count++] = (byte)n;
                n >>>= 8;
            }
        }

        return md5;
    }

    private String toHex(byte[] bytes) {

        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b & 0xFF));
        }
        return sb.toString();
    }

    public static String of(String input) {

        byte[] md5 = instance.compute(input.getBytes());
        return instance.toHex(md5);
    }
}

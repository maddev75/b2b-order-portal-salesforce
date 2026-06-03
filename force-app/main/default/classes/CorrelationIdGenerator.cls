public with sharing class CorrelationIdGenerator {

    public static String generate() {
        return EncodingUtil.convertToHex(
            Crypto.generateDigest(
                'SHA-256',
                Blob.valueOf(
                    String.valueOf(Datetime.now().getTime()) +
                    String.valueOf(Math.random())
                )
            )
        );
    }
}
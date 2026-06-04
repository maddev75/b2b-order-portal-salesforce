public with sharing class RetryPolicy {

    private static final Integer MAX_RETRIES = 3;

    public static Integer getMaxRetries() {
        return MAX_RETRIES;
    }

    public static Boolean isRetryable(Exception e) {

        if (e == null) {
            return false;
        }

        if (e instanceof System.CalloutException) {
            return true;
        }

        return false;
    }
}
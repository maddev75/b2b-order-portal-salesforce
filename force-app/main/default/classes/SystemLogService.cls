public with sharing class SystemLogService {

    public static void logInfo(String name, String context, String message, String status, Id orderId, Id paymentId) {
        insertLog(name, 'INFO', context, message, status, orderId, paymentId, null);
    }

    public static void logWarn(String name, String context, String message, String status, Id orderId, Id paymentId) {
        insertLog(name, 'WARN', context, message, status, orderId, paymentId, null);
    }

    public static void logError(String name, String context, String message, String status, Id orderId, Id paymentId, Exception e) {
        insertLog(
            name,
            'ERROR',
            context,
            message,
            status,
            orderId,
            paymentId,
            e != null ? e.getStackTraceString() : null
        );
    }

    private static void insertLog(
        String name,
        String level,
        String context,
        String message,
        String status,
        Id orderId,
        Id paymentId,
        String stacktrace
    ) {
        System_Log__c logRecord = new System_Log__c();
        //logRecord.Name = name;
        logRecord.Level__c = level;
        logRecord.Context__c = context;
        logRecord.Message__c = message;
        logRecord.Status__c = status;
        logRecord.Related_Order__c = orderId;
        logRecord.Related_Payment__c = paymentId;
        logRecord.Stacktrace__c = stacktrace;
        logRecord.Logged_At__c = System.now();

        insert logRecord;
    }
}
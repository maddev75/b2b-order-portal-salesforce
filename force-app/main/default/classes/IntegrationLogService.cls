public with sharing class IntegrationLogService {

    public static void log(IntegrationLogContext ctx) {
        if (ctx == null) {
            return;
        }

        Integration_Log__c logRecord = new Integration_Log__c();

        logRecord.External_System__c = ctx.externalSystem;
        logRecord.Endpoint__c = ctx.endpoint;
        logRecord.Method__c = ctx.method;
        logRecord.Request_Body__c = ctx.requestBody;
        logRecord.Response_Body__c = ctx.responseBody;
        logRecord.Status_Code__c = ctx.statusCode;
        logRecord.Status__c = ctx.status;
        logRecord.Error_Message__c = ctx.errorMessage;
        logRecord.Duration_Ms__c = ctx.durationMs;
        logRecord.Correlation_Id__c = ctx.correlationId;
        logRecord.Retry_Count__c = ctx.retryCount;
        logRecord.Related_Order__c = ctx.relatedOrderId;
        logRecord.Related_Payment__c = ctx.relatedPaymentId;
        logRecord.Logged_At__c = System.now();

        insert logRecord;
    }
}
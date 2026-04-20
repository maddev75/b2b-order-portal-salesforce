@IsTest
private class SystemLogServiceTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
    }

    private static Order__c getOrder() {
        return [
            SELECT Id
            FROM Order__c
            LIMIT 1
        ];
    }

    @IsTest
    static void testLogInfoCreatesLog() {
        Order__c orderRecord = getOrder();

        Test.startTest();
        SystemLogService.logInfo(
            'ORDER_SUBMIT',
            'OrderService.submitOrder',
            'Order submitted successfully.',
            'Resolved',
            orderRecord.Id,
            null
        );
        Test.stopTest();

        System_Log__c logRecord = [
            SELECT Level__c, Context__c, Message__c, Status__c, Related_Order__c, Logged_At__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
            AND Context__c = 'OrderService.submitOrder'
            AND Level__c = 'INFO'
            LIMIT 1
        ];

        System.assertEquals('INFO', logRecord.Level__c);
        System.assertEquals('OrderService.submitOrder', logRecord.Context__c);
        System.assertEquals('Order submitted successfully.', logRecord.Message__c);
        System.assertEquals('Resolved', logRecord.Status__c);
        System.assertEquals(orderRecord.Id, logRecord.Related_Order__c);
        System.assertNotEquals(null, logRecord.Logged_At__c);
    }

    @IsTest
    static void testLogWarnCreatesLog() {
        Order__c orderRecord = getOrder();

        Test.startTest();
        SystemLogService.logWarn(
            'PAYMENT_FAILURE',
            'PaymentIntegrationService.applyGatewayResult',
            'HTTP payment request failed.',
            'Open',
            orderRecord.Id,
            null
        );
        Test.stopTest();

        System_Log__c logRecord = [
            SELECT Level__c, Context__c, Message__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
            AND Context__c = 'PaymentIntegrationService.applyGatewayResult'
            AND Level__c = 'WARN'
            LIMIT 1
        ];

        System.assertEquals('WARN', logRecord.Level__c);
        System.assertEquals('PaymentIntegrationService.applyGatewayResult', logRecord.Context__c);
        System.assertEquals('HTTP payment request failed.', logRecord.Message__c);
        System.assertEquals('Open', logRecord.Status__c);
        System.assertEquals(orderRecord.Id, logRecord.Related_Order__c);
    }

    @IsTest
    static void testLogErrorCreatesStacktrace() {
        Order__c orderRecord = getOrder();

        Exception capturedException;
        try {
            Integer x = 1 / 0;
        } catch (Exception e) {
            capturedException = e;
        }

        Test.startTest();
        SystemLogService.logError(
            'PAYMENT_ERROR',
            'PaymentIntegrationService.processPayment',
            'Unexpected payment error.',
            'Open',
            orderRecord.Id,
            null,
            capturedException
        );
        Test.stopTest();

        System_Log__c logRecord = [
            SELECT Level__c, Context__c, Message__c, Status__c, Related_Order__c, Stacktrace__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
            AND Context__c = 'PaymentIntegrationService.processPayment'
            AND Level__c = 'ERROR'
            LIMIT 1
        ];

        System.assertEquals('ERROR', logRecord.Level__c);
        System.assertEquals('PaymentIntegrationService.processPayment', logRecord.Context__c);
        System.assertEquals('Unexpected payment error.', logRecord.Message__c);
        System.assertEquals('Open', logRecord.Status__c);
        System.assertEquals(orderRecord.Id, logRecord.Related_Order__c);
        System.assertNotEquals(null, logRecord.Stacktrace__c);
    }
}
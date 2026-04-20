@IsTest
private class SystemLogServiceTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'ProEquip Log Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'Logger',
            Email = 'logger@test.com',
            AccountId = acc.Id
        );
        insert con;

        Order__c orderRecord = new Order__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Status__c = 'Draft',
            Payment_Status__c = 'Pending',
            Order_Date__c = Date.today(),
            Total_Amount__c = 100
        );
        insert orderRecord;
    }

    @IsTest
    static void testLogInfoCreatesLog() {
        Order__c orderRecord = [SELECT Id FROM Order__c LIMIT 1];

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
            SELECT Name, Level__c, Context__c, Message__c, Status__c, Related_Order__c
            FROM System_Log__c
            LIMIT 1
        ];

        System.assertEquals('ORDER_SUBMIT', logRecord.Name);
        System.assertEquals('INFO', logRecord.Level__c);
        System.assertEquals('Resolved', logRecord.Status__c);
        System.assertEquals(orderRecord.Id, logRecord.Related_Order__c);
    }

    @IsTest
    static void testLogErrorCreatesStacktrace() {
        Order__c orderRecord = [SELECT Id FROM Order__c LIMIT 1];

        Exception ex;
        try {
            Integer x = 1 / 0;
        } catch (Exception e) {
            ex = e;
        }

        Test.startTest();
        SystemLogService.logError(
            'PAYMENT_ERROR',
            'PaymentIntegrationService.processPayment',
            'Unexpected payment error.',
            'Open',
            orderRecord.Id,
            null,
            ex
        );
        Test.stopTest();

        System_Log__c logRecord = [
            SELECT Name, Level__c, Stacktrace__c
            FROM System_Log__c
            WHERE Name = 'PAYMENT_ERROR'
            LIMIT 1
        ];

        System.assertEquals('ERROR', logRecord.Level__c);
        System.assertNotEquals(null, logRecord.Stacktrace__c);
    }
}
@IsTest
private class PaymentGatewayClientTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);
        Product2 prod = TestDataFactory.createProduct('3000', 100);
        TestDataFactory.createDraftOrderWithLines(acc.Id, con.Id, prod.id, 1);
    }

    @IsTest
    static void testProcessPaymentReturnsSuccessWhenHttp200() {
        Order__c orderRecord = [
            SELECT Id, Name, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            LIMIT 1
        ];

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(200, '{"result":"ok"}')
        );

        Test.startTest();
        PaymentGatewayResult result = PaymentGatewayClient.processPayment(orderRecord);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess);
        System.assertEquals('APPROVED', result.status);
        System.assertEquals(200, result.httpStatusCode);
        System.assertNotEquals(null, result.rawResponse);
    }

    @IsTest
    static void testProcessPaymentReturnsFailureWhenHttp500() {
        Order__c orderRecord = [
            SELECT Id, Name, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            LIMIT 1
        ];

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(500, '{"result":"error"}')
        );

        Test.startTest();
        PaymentGatewayResult result = PaymentGatewayClient.processPayment(orderRecord);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess);
        System.assertEquals('DECLINED', result.status);
        System.assertEquals(500, result.httpStatusCode);
    }
}
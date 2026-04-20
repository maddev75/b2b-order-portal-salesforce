@IsTest
private class PaymentQueueableTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        Product2 product = TestDataFactory.createProduct('QUEUE-TST-001', 150);

        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 2); // total 300

        orderRecord.Status__c = 'Submitted';
        orderRecord.Payment_Status__c = 'Pending';
        update orderRecord;
    }

    private static Order__c getSubmittedOrder() {
        return [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Total_Amount__c = 300
            LIMIT 1
        ];
    }

    @IsTest
    static void testQueueableProcessesPaymentSuccessfully() {
        Order__c orderRecord = getSubmittedOrder();

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                200,
                '{"result":"ok","reference":"HTTPBIN-QUEUE-123"}'
            )
        );

        Test.startTest();
        System.enqueueJob(new PaymentQueueable(orderRecord.Id));
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Id, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Paid', updatedOrder.Payment_Status__c);

        List<System_Log__c> logs = [
            SELECT Level__c, Context__c, Message__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];

        Boolean hasPaymentRequest = false;
        Boolean hasPaymentSuccess = false;

        for (System_Log__c logRecord : logs) {
            if (
                logRecord.Context__c == 'PaymentIntegrationService.processPayment' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Open'
            ) {
                hasPaymentRequest = true;
            }

            if (
                logRecord.Context__c == 'PaymentIntegrationService.applyGatewayResult' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Resolved'
            ) {
                hasPaymentSuccess = true;
            }
        }

        System.assertEquals(true, hasPaymentRequest, 'PAYMENT_REQUEST log should exist.');
        System.assertEquals(true, hasPaymentSuccess, 'PAYMENT_SUCCESS log should exist.');
    }

    @IsTest
    static void testQueueableMarksPaymentFailedWhenCalloutFails() {
        Order__c orderRecord = getSubmittedOrder();

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                500,
                '{"error":"gateway_down"}'
            )
        );

        Test.startTest();
        System.enqueueJob(new PaymentQueueable(orderRecord.Id));
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Id, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Failed', updatedOrder.Payment_Status__c);

        List<System_Log__c> logs = [
            SELECT Level__c, Context__c, Message__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];

        Boolean hasPaymentRequest = false;
        Boolean hasPaymentFailure = false;

        for (System_Log__c logRecord : logs) {
            if (
                logRecord.Context__c == 'PaymentIntegrationService.processPayment' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Open'
            ) {
                hasPaymentRequest = true;
            }

            if (
                logRecord.Context__c == 'PaymentIntegrationService.applyGatewayResult' &&
                logRecord.Level__c == 'WARN' &&
                logRecord.Status__c == 'Open'
            ) {
                hasPaymentFailure = true;
            }
        }

        System.assertEquals(true, hasPaymentRequest, 'PAYMENT_REQUEST log should exist.');
        System.assertEquals(true, hasPaymentFailure, 'PAYMENT_FAILURE log should exist.');
    }
}
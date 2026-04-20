@IsTest
private class PaymentIntegrationServiceTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        Product2 product1 = TestDataFactory.createProduct('PAY-TST-001', 100);
        Product2 product2 = TestDataFactory.createProduct('PAY-TST-002', 250);

        Order__c orderSuccess = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderSuccess.Id, product1.Id, 2); // total 200

        Order__c orderFailure = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderFailure.Id, product2.Id, 1); // total 250

        orderSuccess.Status__c = 'Submitted';
        orderFailure.Status__c = 'Submitted';

        // On évite "Processing" dans le setup tant que la picklist n'est pas confirmée
        orderSuccess.Payment_Status__c = 'Pending';
        orderFailure.Payment_Status__c = 'Pending';

        update new List<Order__c>{ orderSuccess, orderFailure };
    }

    private static Order__c getSubmittedOrderSuccess() {
        return [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Total_Amount__c = 200
            LIMIT 1
        ];
    }

    private static Order__c getSubmittedOrderFailure() {
        return [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Total_Amount__c = 250
            LIMIT 1
        ];
    }

    @IsTest
    static void testProcessPaymentMarksOrderPaidOnHttp200() {
        Order__c orderRecord = getSubmittedOrderSuccess();

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                200,
                '{"result":"ok","reference":"HTTPBIN-123"}'
            )
        );

        Test.startTest();
        PaymentIntegrationService.processPayment(orderRecord.Id);
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
    static void testProcessPaymentMarksOrderFailedOnHttp500() {
        Order__c orderRecord = getSubmittedOrderFailure();

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                500,
                '{"error":"gateway_down"}'
            )
        );

        Test.startTest();
        PaymentIntegrationService.processPayment(orderRecord.Id);
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

    @IsTest
    static void testProcessPaymentThrowsBusinessExceptionWhenOrderIdIsNull() {
        try {
            Test.startTest();
            PaymentIntegrationService.processPayment(null);
            Test.stopTest();
            System.assert(false, 'Expected BusinessException was not thrown.');
        } catch (BusinessException e) {
            System.assertEquals('OrderId is required for payment processing.', e.getMessage());
        }
    }
}
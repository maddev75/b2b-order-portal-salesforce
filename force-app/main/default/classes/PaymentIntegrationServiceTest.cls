@IsTest
private class PaymentIntegrationServiceTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        // Produits
        TestDataFactory.createProduct('PAY-TST-001', 100);
        TestDataFactory.createProduct('PAY-TST-002', 250);

        Product2 product1 = [
            SELECT Id, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PAY-TST-001'
            LIMIT 1
        ];

        Product2 product2 = [
            SELECT Id, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PAY-TST-002'
            LIMIT 1
        ];

        // Commande succès
        Order__c orderSuccess = new Order__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Status__c = 'Submitted',
            Payment_Status__c = 'Processing',
            Order_Date__c = Date.today(),
            Total_Amount__c = 200
        );
        insert orderSuccess;

        insert new Order_Line__c(
            Order__c = orderSuccess.Id,
            Product__c = product1.Id,
            Quantity__c = 2,
            Unit_Price__c = product1.Base_Price__c
            //Line_Total__c = 200
        );

        // Commande échec
        Order__c orderFailure = new Order__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Status__c = 'Submitted',
            Payment_Status__c = 'Processing',
            Order_Date__c = Date.today(),
            Total_Amount__c = 250
        );
        insert orderFailure;

        insert new Order_Line__c(
            Order__c = orderFailure.Id,
            Product__c = product2.Id,
            Quantity__c = 1,
            Unit_Price__c = product2.Base_Price__c
            //Line_Total__c = 250
        );
    }

    private static Order__c getSubmittedOrderSuccess() {
        return [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Status__c = 'Submitted'
            AND Payment_Status__c = 'Processing'
            AND Total_Amount__c = 200
            LIMIT 1
        ];
    }

    private static Order__c getSubmittedOrderFailure() {
        return [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Status__c = 'Submitted'
            AND Payment_Status__c = 'Processing'
            AND Total_Amount__c = 250
            LIMIT 1
        ];
    }

    @IsTest
    static void testProcessPaymentMarksOrderConfirmedOnHttp200() {
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
            SELECT Id, Status__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Confirmed', updatedOrder.Status__c);
        System.assertEquals('Success', updatedOrder.Payment_Status__c);

        List<System_Log__c> logs = [
            SELECT Level__c, Context__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];

        Boolean hasPaymentRequest = false;
        Boolean hasPaymentSuccess = false;

        for (System_Log__c logRecord : logs) {
            if (
                logRecord.Context__c == 'PaymentIntegrationService.processPayment' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Resolved'
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

        System.assertEquals(true, hasPaymentRequest);
        System.assertEquals(true, hasPaymentSuccess);
    }

    @IsTest
    static void testProcessPaymentMarksOrderPaymentFailedOnHttp500() {
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
            SELECT Id, Status__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Payment Failed', updatedOrder.Status__c);
        System.assertEquals('Failed', updatedOrder.Payment_Status__c);

        List<System_Log__c> logs = [
            SELECT Level__c, Context__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];

        Boolean hasPaymentRequest = false;
        Boolean hasPaymentFailure = false;

        for (System_Log__c logRecord : logs) {
            if (
                logRecord.Context__c == 'PaymentIntegrationService.processPayment' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Resolved'
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

        System.assertEquals(true, hasPaymentRequest);
        System.assertEquals(true, hasPaymentFailure);
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
    
    @IsTest
    static void testProcessPaymentHandlesTechnicalFailureOnCalloutException() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);
        Product2 product = TestDataFactory.createProduct('PAY-EXC-001', 100);
    
        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 2);
    
        orderRecord = [
            SELECT Id, Status__c, Payment_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];
    
        orderRecord.Status__c = 'Submitted';
        orderRecord.Payment_Status__c = 'Processing';
        orderRecord.Total_Amount__c = 200;
        update orderRecord;
    
        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpExceptionMock()
        );
    
        try {
            Test.startTest();
            PaymentIntegrationService.processPayment(orderRecord.Id);
            Test.stopTest();
            System.assert(false, 'Expected exception was not thrown.');
        } catch (Exception e) {
            System.assert(
                e.getMessage().contains('Simulated callout exception'),
                'Unexpected exception message: ' + e.getMessage()
            );
        }
    
        Order__c updatedOrder = [
            SELECT Id, Status__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];
    
        System.assertEquals('Payment Failed', updatedOrder.Status__c);
        System.assertEquals('Failed', updatedOrder.Payment_Status__c);
    
        List<System_Log__c> logs = [
            SELECT Level__c, Context__c, Status__c, Related_Order__c, Stacktrace__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
            AND Context__c = 'PaymentIntegrationService.processPayment'
            AND Level__c = 'ERROR'
        ];
    
        System.assertEquals(1, logs.size(), 'Expected one PAYMENT_ERROR log.');
        System.assertEquals('Open', logs[0].Status__c);
        System.assertNotEquals(null, logs[0].Stacktrace__c);
    }
}
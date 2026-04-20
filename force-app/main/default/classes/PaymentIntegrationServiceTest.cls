@IsTest
private class PaymentIntegrationServiceTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'ProEquip Integration Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'Integrator',
            Email = 'integrator@test.com',
            AccountId = acc.Id
        );
        insert con;

        Order__c orderSuccess = new Order__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Status__c = 'Submitted',
            Payment_Status__c = 'Processing',
            Order_Date__c = Date.today(),
            Total_Amount__c = 3000
        );

        Order__c orderFailure = new Order__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Status__c = 'Submitted',
            Payment_Status__c = 'Processing',
            Order_Date__c = Date.today(),
            Total_Amount__c = 8000
        );

        insert new List<Order__c>{ orderSuccess, orderFailure };
    }

    @IsTest
    static void testProcessPaymentMarksOrderPaidOnHttp200() {
        Order__c orderRecord = [
            SELECT Id, Payment_Status__c
            FROM Order__c
            WHERE Total_Amount__c = 3000
            LIMIT 1
        ];

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                200,
                '{"result":"ok"}'
            )
        );

        Test.startTest();
        PaymentIntegrationService.processPayment(orderRecord.Id);
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Paid', updatedOrder.Payment_Status__c);

        List<System_Log__c> logs = [
            SELECT Name, Level__c, Status__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];

        System.assert(logs.size() >= 2, 'Expected at least PAYMENT_REQUEST and PAYMENT_SUCCESS logs');
    }

    @IsTest
    static void testProcessPaymentMarksOrderFailedOnHttp500() {
        Order__c orderRecord = [
            SELECT Id, Payment_Status__c
            FROM Order__c
            WHERE Total_Amount__c = 8000
            LIMIT 1
        ];

        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                500,
                '{"result":"error"}'
            )
        );

        Test.startTest();
        PaymentIntegrationService.processPayment(orderRecord.Id);
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals('Failed', updatedOrder.Payment_Status__c);

        System_Log__c failureLog = [
            SELECT Name, Level__c, Status__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
            AND Name = 'PAYMENT_FAILURE'
            LIMIT 1
        ];

        System.assertEquals('WARN', failureLog.Level__c);
        System.assertEquals('Open', failureLog.Status__c);
    }

    @IsTest
    static void testProcessPaymentThrowsWhenOrderIdIsNull() {
        try {
            Test.startTest();
            PaymentIntegrationService.processPayment(null);
            Test.stopTest();
            System.assert(false, 'Expected BusinessException');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('OrderId is required'));
        }
    }
}
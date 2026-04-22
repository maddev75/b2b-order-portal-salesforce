@isTest
private class OrderServiceTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        TestDataFactory.createProduct('PROEQ-TST-001', 100);
        TestDataFactory.createProduct('PROEQ-TST-002', 250);
    }

    private static Account getAccount() {
        return [SELECT Id, Name FROM Account WHERE Name = 'ACME Test' LIMIT 1];
    }

    private static Contact getContact() {
        return [SELECT Id, LastName, AccountId FROM Contact WHERE LastName = 'Doe' LIMIT 1];
    }

    private static Product2 getProduct1() {
        return [
            SELECT Id, Name, ProductCode, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PROEQ-TST-001'
            LIMIT 1
        ];
    }

    private static Product2 getProduct2() {
        return [
            SELECT Id, Name, ProductCode, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PROEQ-TST-002'
            LIMIT 1
        ];
    }

    @isTest
    static void testCreateDraftOrder_setsExpectedDefaultValues() {
        Account acc = getAccount();
        Contact con = getContact();

        Test.startTest();
        Id orderId = OrderService.createDraftOrder(acc.Id, con.Id);
        Test.stopTest();

        Order__c orderRecord = [
            SELECT Id, Account__c, Contact__c, Status__c, Order_Date__c,
                   Total_Amount__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        System.assertNotEquals(null, orderRecord.Id);
        System.assertEquals(acc.Id, orderRecord.Account__c);
        System.assertEquals(con.Id, orderRecord.Contact__c);
        System.assertEquals('Draft', orderRecord.Status__c);
        System.assertEquals(Date.today(), orderRecord.Order_Date__c);
        System.assertEquals(0, orderRecord.Total_Amount__c);
        System.assertEquals('Pending', orderRecord.Payment_Status__c);
    }

    @isTest
    static void testGetOrdersByAccount_returnsOrdersForAccount() {
        Account acc = getAccount();
        Contact con = getContact();

        TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.createDraftOrder(acc.Id, con.Id);

        Test.startTest();
        List<Order__c> orders = OrderService.getOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(2, orders.size());
    }

    @isTest
    static void testGetOrderDetail_returnsOrderAndLines() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 2);

        Test.startTest();
        OrderDetailDTO detail = OrderService.getOrderDetail(orderRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, detail);
        System.assertEquals(orderRecord.Id, detail.orderRecord.Id);
        System.assertEquals(1, detail.orderLines.size());
    }

    @isTest
    static void testAddOrderLine_createsLineAndRecalculatesOrderTotal() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);

        Test.startTest();
        Order_Line__c createdLine = OrderService.addOrderLine(orderRecord.Id, product.Id, 2);
        Test.stopTest();

        Order_Line__c lineFromDb = [
            SELECT Id, Order__c, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Order_Line__c
            WHERE Id = :createdLine.Id
        ];

        Order__c refreshedOrder = [
            SELECT Id, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals(orderRecord.Id, lineFromDb.Order__c);
        System.assertEquals(product.Id, lineFromDb.Product__c);
        System.assertEquals(2, lineFromDb.Quantity__c);
        System.assertEquals(100, lineFromDb.Unit_Price__c);
        System.assertEquals(200, lineFromDb.Line_Total__c);
        System.assertEquals(200, refreshedOrder.Total_Amount__c);
    }

    @isTest
    static void testUpdateOrderLine_updatesQuantityAndOrderTotal() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        Order_Line__c line = TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 2);

        Test.startTest();
        OrderService.updateOrderLine(line.Id, 5);
        Test.stopTest();

        Order_Line__c updatedLine = [
            SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c, Order__c
            FROM Order_Line__c
            WHERE Id = :line.Id
        ];

        Order__c refreshedOrder = [
            SELECT Id, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals(5, updatedLine.Quantity__c);
        System.assertEquals(500, updatedLine.Line_Total__c);
        System.assertEquals(500, refreshedOrder.Total_Amount__c);
    }

    @isTest
    static void testSubmitOrder_updatesOrderAndLaunchesQueueable() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();
    
        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 2);
    
        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                200,
                '{"result":"ok","reference":"HTTPBIN-123"}'
            )
        );
    
        Test.startTest();
        OrderService.submitOrder(orderRecord.Id);
        Test.stopTest();
    
        Order__c refreshedOrder = [
            SELECT Id, Status__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];
    
        // Comme le Queueable s'exécute pendant Test.stopTest(),
        // on vérifie l'état final après intégration.
        System.assertEquals('Confirmed', refreshedOrder.Status__c);
        System.assertEquals('Success', refreshedOrder.Payment_Status__c);
    
        List<System_Log__c> logs = [
            SELECT Context__c, Level__c, Status__c, Related_Order__c
            FROM System_Log__c
            WHERE Related_Order__c = :orderRecord.Id
        ];
    
        Boolean hasOrderSubmitLog = false;
    
        for (System_Log__c logRecord : logs) {
            if (
                logRecord.Context__c == 'OrderService.submitOrder' &&
                logRecord.Level__c == 'INFO' &&
                logRecord.Status__c == 'Resolved'
            ) {
                hasOrderSubmitLog = true;
            }
        }
    
        System.assertEquals(true, hasOrderSubmitLog, 'ORDER_SUBMIT log should exist.');
    }
    
    @isTest
    static void testSubmitOrder_marksOrderFailedWhenCalloutFails() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct2();
    
        Order__c orderRecord = TestDataFactory.createDraftOrder(acc.Id, con.Id);
        TestDataFactory.addOrderLine(orderRecord.Id, product.Id, 1);
    
        Test.setMock(
            HttpCalloutMock.class,
            new PaymentGatewayHttpMock(
                500,
                '{"error":"gateway_down"}'
            )
        );
    
        Test.startTest();
        OrderService.submitOrder(orderRecord.Id);
        Test.stopTest();
    
        Order__c refreshedOrder = [
            SELECT Id, Status__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];
    
        System.assertEquals('Payment Failed', refreshedOrder.Status__c);
        System.assertEquals('Failed', refreshedOrder.Payment_Status__c);
    }
    
    @isTest
    static void testSubmitOrder_throwsExceptionWhenOrderIdIsNull() {
        try {
            OrderService.submitOrder(null);
            System.assert(false, 'Expected BusinessException was not thrown.');
        } catch (BusinessException e) {
            System.assertEquals('Order not found.', e.getMessage());
        }
    }
}
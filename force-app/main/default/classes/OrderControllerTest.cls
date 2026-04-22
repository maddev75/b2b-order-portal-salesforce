@isTest
private class OrderControllerTest {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact(acc.Id);

        TestDataFactory.createProduct('PROEQ-CTRL-001', 150);
        TestDataFactory.createProduct('PROEQ-CTRL-002', 200);
    }

    private static Account getAccount() {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'ACME Test'
            LIMIT 1
        ];
    }

    private static Contact getContact() {
        return [
            SELECT Id, LastName, AccountId
            FROM Contact
            WHERE LastName = 'Doe'
            LIMIT 1
        ];
    }

    private static Product2 getProduct1() {
        return [
            SELECT Id, Name, ProductCode, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PROEQ-CTRL-001'
            LIMIT 1
        ];
    }

    private static Product2 getProduct2() {
        return [
            SELECT Id, Name, ProductCode, Base_Price__c
            FROM Product2
            WHERE ProductCode = 'PROEQ-CTRL-002'
            LIMIT 1
        ];
    }

    @isTest
    static void testControllerCreateAndReadOrder() {
        Account acc = getAccount();
        Contact con = getContact();

        Test.startTest();
        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);
        List<Order__c> orders = OrderController.getMyOrders(acc.Id);
        OrderDetailDTO detail = OrderController.getOrderDetail(orderId);
        Test.stopTest();

        System.assertNotEquals(null, orderId);
        System.assertEquals(1, orders.size());
        System.assertEquals(orderId, detail.orderRecord.Id);
        System.assertEquals(0, detail.orderLines.size());
    }

    @isTest
    static void testControllerAddOrderLine() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);

        Test.startTest();
        Order_Line__c line = OrderController.addOrderLine(orderId, product.Id, 2);
        Test.stopTest();

        Order_Line__c lineFromDb = [
            SELECT Id, Order__c, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Order_Line__c
            WHERE Id = :line.Id
        ];

        Order__c orderRecord = [
            SELECT Id, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        System.assertNotEquals(null, lineFromDb.Id);
        System.assertEquals(orderId, lineFromDb.Order__c);
        System.assertEquals(product.Id, lineFromDb.Product__c);
        System.assertEquals(2, lineFromDb.Quantity__c);
        System.assertEquals(150, lineFromDb.Unit_Price__c);
        System.assertEquals(300, lineFromDb.Line_Total__c);
        System.assertEquals(300, orderRecord.Total_Amount__c);
    }

    @isTest
    static void testControllerUpdateOrderLine() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);
        Order_Line__c line = OrderController.addOrderLine(orderId, product.Id, 2);

        Test.startTest();
        OrderController.updateOrderLine(line.Id, 5);
        Test.stopTest();

        Order_Line__c updatedLine = [
            SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c, Order__c
            FROM Order_Line__c
            WHERE Id = :line.Id
        ];

        Order__c orderRecord = [
            SELECT Id, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        System.assertEquals(5, updatedLine.Quantity__c);
        System.assertEquals(750, updatedLine.Line_Total__c);
        System.assertEquals(750, orderRecord.Total_Amount__c);
    }

    @isTest
    static void testControllerDeleteOrderLine() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product1 = getProduct1();
        Product2 product2 = getProduct2();

        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);
        Order_Line__c line1 = OrderController.addOrderLine(orderId, product1.Id, 2); // 300
        Order_Line__c line2 = OrderController.addOrderLine(orderId, product2.Id, 1); // 200

        Test.startTest();
        OrderController.deleteOrderLine(line2.Id);
        Test.stopTest();

        List<Order_Line__c> remainingLines = [
            SELECT Id
            FROM Order_Line__c
            WHERE Order__c = :orderId
        ];

        Order__c orderRecord = [
            SELECT Id, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        System.assertEquals(1, remainingLines.size());
        System.assertEquals(300, orderRecord.Total_Amount__c);
    }

    /*@isTest
    static void testControllerSubmitOrder() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);
        OrderController.addOrderLine(orderId, product.Id, 2);

        Test.startTest();
        OrderController.submitOrder(orderId);
        Test.stopTest();

        Order__c orderRecord = [
            SELECT Id, Status__c, Total_Amount__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        System.assertEquals('Submitted', orderRecord.Status__c);
        System.assertEquals(300, orderRecord.Total_Amount__c);
    }*/

    @isTest
    static void testControllerGetMyOrdersReturnsMultipleOrders() {
        Account acc = getAccount();
        Contact con = getContact();

        OrderController.createDraftOrder(acc.Id, con.Id);
        OrderController.createDraftOrder(acc.Id, con.Id);

        Test.startTest();
        List<Order__c> orders = OrderController.getMyOrders(acc.Id);
        Test.stopTest();

        System.assertEquals(2, orders.size());
    }

    @isTest
    static void testControllerGetOrderDetailReturnsLines() {
        Account acc = getAccount();
        Contact con = getContact();
        Product2 product = getProduct1();

        Id orderId = OrderController.createDraftOrder(acc.Id, con.Id);
        OrderController.addOrderLine(orderId, product.Id, 2);

        Test.startTest();
        OrderDetailDTO detail = OrderController.getOrderDetail(orderId);
        Test.stopTest();

        System.assertEquals(orderId, detail.orderRecord.Id);
        System.assertEquals(1, detail.orderLines.size());
    }
}
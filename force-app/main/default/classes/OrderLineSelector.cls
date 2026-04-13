public with sharing class OrderLineSelector {

    public static Order_Line__c getById(Id lineId) {
        List<Order_Line__c> lines = [
            SELECT Id, Name, Order__c, Product__c, Product__r.Name, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Order_Line__c
            WHERE Id = :lineId
            LIMIT 1
        ];

        if (lines.isEmpty()) {
            throw new BusinessException('Order line not found.');
        }
        return lines[0];
    }

    public static List<Order_Line__c> getByOrderId(Id orderId) {
        return [
            SELECT Id, Name, Product__c, Product__r.Name, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Order_Line__c
            WHERE Order__c = :orderId
            ORDER BY CreatedDate ASC
        ];
    }
}
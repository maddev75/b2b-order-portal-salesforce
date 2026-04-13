public with sharing class OrderSelector {

    public static List<Order__c> getByAccount(Id accountId) {
        return [
            SELECT Id, Name, Status__c, Order_Date__c, Total_Amount__c, Payment_Status__c
            FROM Order__c
            WHERE Account__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }

    public static Order__c getById(Id orderId) {
        List<Order__c> orders = [
            SELECT Id, Name, Status__c, Order_Date__c, Total_Amount__c,
                   Payment_Status__c, Account__c, Contact__c
            FROM Order__c
            WHERE Id = :orderId
            LIMIT 1
        ];

        if (orders.isEmpty()) {
            throw new BusinessException('Order not found.');
        }

        return orders[0];
    }
}
@isTest
public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'ACME Test'
        );
        insert acc;
        return acc;
    }

    public static Contact createContact(Id accountId) {
        Contact con = new Contact(
            LastName = 'Doe',
            AccountId = accountId
        );
        insert con;
        return con;
    }

    public static Product2 createProduct(String code, Decimal basePrice) {
        Product2 product = new Product2(
            Name = 'Product ' + code,
            ProductCode = code,
            IsActive = true,
            Base_Price__c = basePrice
        );
        insert product;
        return product;
    }

    public static Order__c createDraftOrder(Id accountId, Id contactId) {
        Id orderId = OrderService.createDraftOrder(accountId, contactId);
        return [
            SELECT Id, Account__c, Contact__c, Status__c, Order_Date__c,
                   Total_Amount__c, Payment_Status__c
            FROM Order__c
            WHERE Id = :orderId
        ];
    }

    public static Order_Line__c addOrderLine(Id orderId, Id productId, Integer quantity) {
        return OrderService.addOrderLine(orderId, productId, quantity);
    }
}
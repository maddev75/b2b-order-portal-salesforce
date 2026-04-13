public with sharing class OrderLineDomain {

    public static void initializeOrderLine(Order_Line__c line, Id orderId, Product2 product, Integer quantity) {
        validateLineRecordIsProvided(line);
        validateOrderIdIsProvided(orderId);
        validateProductIsProvided(product);
        validateQuantity(quantity);

        line.Order__c = orderId;
        line.Product__c = product.Id;
        line.Quantity__c = quantity;
        line.Unit_Price__c = product.Base_Price__c;
    }
    public static void updateQuantity(Order_Line__c line, Integer quantity) {
        validateLineRecordIsProvided(line);
        validateQuantity(quantity);
        line.Quantity__c = quantity;
    }

    private static void validateLineRecordIsProvided(Order_Line__c line) {
        if (line == null) {
            throw new BusinessException('Line record is required.');
        }
    }

    private static void validateOrderIdIsProvided(Id orderId) {
        if (orderId == null) {
            throw new BusinessException('Order is required to create a line.');
        }
    }

    private static void validateProductIsProvided(Product2 product) {
        if (product == null) {
            throw new BusinessException('Product is required to create a line.');
        }
    }

    private static void validateQuantity(Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new BusinessException('Quantity must be greater than 0.');
        }
    }
}
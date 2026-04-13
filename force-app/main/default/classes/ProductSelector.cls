public with sharing class ProductSelector {

    public static Product2 getProductById(Id productId) {
        List<Product2> products = [
            SELECT Id, Name, Base_Price__c
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];

        if (products.isEmpty()) {
            throw new BusinessException('Product not found.');
        }

        return products[0];
    }

    public static List<Product2> getActiveProducts() {
        return [
            SELECT Id, Name, ProductCode, Base_Price__c
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name ASC
        ];
    }
}
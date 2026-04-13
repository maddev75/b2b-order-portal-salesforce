public with sharing class ProductController {

    @AuraEnabled
    public static List<Product2> getActiveProducts() {
        try {
            return ProductService.getActiveProducts();
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }
}
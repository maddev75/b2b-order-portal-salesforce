public with sharing class ProductService {

    public static List<Product2> getActiveProducts() {
        return ProductSelector.getActiveProducts();
    }
}
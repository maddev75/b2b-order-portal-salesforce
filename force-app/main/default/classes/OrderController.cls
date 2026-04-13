public with sharing class OrderController {

    @AuraEnabled
    public static List<Order__c> getMyOrders(Id accountId) {
        try {
            return OrderService.getOrdersByAccount(accountId);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        }
        catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }

    @AuraEnabled
    public static OrderDetailDTO getOrderDetail(Id orderId) {
        try {
            return OrderService.getOrderDetail(orderId);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }

    @AuraEnabled
    public static Id createDraftOrder(Id accountId, Id contactId) {
        try {
            return OrderService.createDraftOrder(accountId, contactId);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }
    
    @AuraEnabled
    public static Order_Line__c addOrderLine(Id orderId, Id productId, Integer quantity) {
        try {
            return OrderService.addOrderLine(orderId, productId, quantity);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }

    @AuraEnabled
    public static void updateOrderLine(Id lineId, Integer quantity) {
        try {
            OrderService.updateOrderLine(lineId, quantity);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }

    @AuraEnabled
    public static void deleteOrderLine(Id lineId) {
        try {
            OrderService.deleteOrderLine(lineId);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }

    @AuraEnabled
    public static void submitOrder(Id orderId) {
        try {
             OrderService.submitOrder(orderId);
        } catch (BusinessException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }
}
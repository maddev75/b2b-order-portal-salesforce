public with sharing class OrderService {

    public static List<Order__c> getOrdersByAccount(Id accountId) {
        return OrderSelector.getByAccount(accountId);
    }

    public static OrderDetailDTO getOrderDetail(Id orderId) {
        Order__c orderRecord = OrderSelector.getById(orderId);
        List<Order_Line__c> orderLines = OrderLineSelector.getByOrderId(orderId);
    
        return new OrderDetailDTO(orderRecord, orderLines);
    }

    public static Id createDraftOrder(Id accountId, Id contactId) {
        Order__c orderRecord = new Order__c();

        OrderDomain.initializeDraftOrder(orderRecord, accountId, contactId);

        insert orderRecord;

        return orderRecord.Id;
    }

    public static Order_Line__c addOrderLine(Id orderId, Id productId, Integer quantity) {
        Order__c orderRecord = OrderSelector.getById(orderId);
        OrderDomain.isOrderEditable(orderRecord);
    
        Product2 product = ProductSelector.getProductById(productId);
    
        Order_Line__c line = new Order_Line__c();
        OrderLineDomain.initializeOrderLine(line, orderId, product, quantity);
    
        insert line;
    
        List<Order_Line__c> orderLines = OrderLineSelector.getByOrderId(orderId);
        OrderDomain.recalculateTotal(orderRecord, orderLines);
    
        update orderRecord;
        return line;
    }

    public static void updateOrderLine(Id lineId, Integer quantity) {

        Order_Line__c line = OrderLineSelector.getById(lineId);
        Order__c orderRecord = OrderSelector.getById(line.Order__c);
        OrderDomain.isOrderEditable(orderRecord);
        OrderLineDomain.updateQuantity(line, quantity);
        
        update line;
    
        List<Order_Line__c> orderLines = OrderLineSelector.getByOrderId(orderRecord.Id);
        OrderDomain.recalculateTotal(orderRecord, orderLines);
        
        update orderRecord;
    }

    public static void deleteOrderLine(Id lineId) {

        if (lineId == null) {
            throw new BusinessException('LineId is required.');
        }
    
        Order_Line__c line = OrderLineSelector.getById(lineId);
        Order__c orderRecord = OrderSelector.getById(line.Order__c);
        OrderDomain.isOrderEditable(orderRecord);
    
        delete line;
    
        List<Order_Line__c> orderLines = OrderLineSelector.getByOrderId(orderRecord.Id);
        OrderDomain.recalculateTotal(orderRecord, orderLines);
    
        update orderRecord;
    }


    public static void submitOrder(Id orderId) {

        Order__c orderRecord = OrderSelector.getById(orderId);
        List<Order_Line__c> orderLines = OrderLineSelector.getByOrderId(orderId);
    
        OrderDomain.validateCanBeSubmitted(orderRecord, orderLines);
        OrderDomain.recalculateTotal(orderRecord, orderLines);
        OrderDomain.markAsSubmitted(orderRecord);
    
        update orderRecord;
    }
}
public class OrderDetailDTO {
    @AuraEnabled public Order__c orderRecord;
    @AuraEnabled public List<Order_Line__c> orderLines;

    public OrderDetailDTO(Order__c orderRecord, List<Order_Line__c> orderLines) {
        this.orderRecord = orderRecord;
        this.orderLines = orderLines;
    }
}
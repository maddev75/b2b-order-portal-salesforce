public class OrderDomain {

    private static final String STATUS_DRAFT = 'Draft';
    private static final String PAYMENT_STATUS_PENDING = 'Pending';
    private static final String STATUS_SUBMITTED = 'Submitted';

    public static void initializeDraftOrder(Order__c orderRecord, Id accountId, Id contactId) {
        validateOrderRecordIsProvided(orderRecord);
        validateAccountIsProvided(accountId);

        orderRecord.Account__c = accountId;
        orderRecord.Contact__c = contactId;
        orderRecord.Status__c = STATUS_DRAFT;
        orderRecord.Order_Date__c = Date.today();
        orderRecord.Total_Amount__c = 0;
        orderRecord.Payment_Status__c = PAYMENT_STATUS_PENDING;

        system.debug(orderRecord+'OrderRecord');
    }

    public static void recalculateTotal(Order__c orderRecord, List<Order_Line__c> orderLines) {
        validateOrderRecord(orderRecord);
    
        Decimal total = 0;
    
        for (Order_Line__c line : orderLines) {
            if (line.Line_Total__c != null) {
                total += line.Line_Total__c;
            }
        }
    
        orderRecord.Total_Amount__c = total;
    }

    public static void validateCanBeSubmitted(Order__c orderRecord, List<Order_Line__c> orderLines) {
        validateOrderRecord(orderRecord);
    
        if (orderRecord.Status__c != 'Draft') {
            throw new BusinessException('Only Draft orders can be submitted.');
        }
    
        if (orderLines == null || orderLines.isEmpty()) {
            throw new BusinessException('An order must contain at least one line before submission.');
        }
    }

    public static void markAsSubmitted(Order__c orderRecord) {
        validateOrderRecord(orderRecord);
        orderRecord.Status__c = STATUS_SUBMITTED;
    }

    public static void  isOrderEditable(Order__c orderRecord) {
        validateOrderRecord(orderRecord);

        if (orderRecord.Status__c != 'Draft') {
            throw new BusinessException('Only Draft orders can be modified.');
        }    
    }

    private static void validateOrderRecordIsProvided(Order__c orderRecord) {
        if (orderRecord == null) {
            throw new BusinessException('Order record is required.');
        }
    }

    private static void validateAccountIsProvided(Id accountId) {
        if (accountId == null) {
            throw new BusinessException('Account is required to create an order.');
        }
    }

    private static void validateOrderRecord(Order__c orderRecord) {
        if (orderRecord == null) {
            throw new BusinessException('Order record is required.');
        }
    }
}
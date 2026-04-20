public with sharing class PaymentGatewayClient {

    public static PaymentGatewayResult processPayment(Order__c orderRecord) {
        validateOrder(orderRecord);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Payment_Gateway/anything/payments');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(10000);

        Map<String, Object> payload = new Map<String, Object>{
            'orderId' => orderRecord.Id,
            'orderName' => orderRecord.Name,
            'status' => orderRecord.Status__c,
            'paymentStatus' => orderRecord.Payment_Status__c,
            'totalAmount' => orderRecord.Total_Amount__c
        };

        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res = http.send(req);

        Integer statusCode = res.getStatusCode();
        String responseBody = res.getBody();

        if (statusCode >= 200 && statusCode < 300) {
            return new PaymentGatewayResult(
                true,
                'APPROVED',
                'HTTP payment request succeeded.',
                'HTTPBIN-' + String.valueOf(orderRecord.Id),
                statusCode,
                responseBody
            );
        }

        return new PaymentGatewayResult(
            false,
            'DECLINED',
            'HTTP payment request failed.',
            'HTTPBIN-' + String.valueOf(orderRecord.Id),
            statusCode,
            responseBody
        );
    }

    private static void validateOrder(Order__c orderRecord) {
        if (orderRecord == null) {
            throw new BusinessException('Order record is required for payment processing.');
        }

        if (orderRecord.Id == null) {
            throw new BusinessException('Order must be persisted before payment processing.');
        }
    }
}
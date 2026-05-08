public with sharing class PaymentGatewayClient {

    private static final String ENDPOINT = 'callout:Proequip_Payment_API_OAuth/api/payments';
    private static final String ENDPOINT_PATH = '/api/payments';
    private static final String METHOD = 'POST';

    public static PaymentGatewayResult processPayment(Order__c orderRecord) {
        validateOrder(orderRecord);

        String correlationId = CorrelationIdGenerator.generate();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod(METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-Correlation-Id', correlationId);
        req.setTimeout(10000);

        Map<String, Object> payload = new Map<String, Object>{
            'orderId' => String.valueOf(orderRecord.Id),
            'accountId' => String.valueOf(orderRecord.Account__c),
            'amount' => orderRecord.Total_Amount__c,
            'currency' => 'EUR',
            'scenario' => 'SUCCESS'
        };

        String requestBody = JSON.serialize(payload);
        req.setBody(requestBody);

        Http http = new Http();
        Long startTime = DateTime.now().getTime();

        try {
            HttpResponse res = http.send(req);

            Long durationMs = DateTime.now().getTime() - startTime;
            Integer statusCode = res.getStatusCode();
            String responseBody = res.getBody();

            IntegrationLogContext logCtx = new IntegrationLogContext();
            logCtx.endpoint = ENDPOINT_PATH;
            logCtx.method = METHOD;
            logCtx.requestBody = requestBody;
            logCtx.responseBody = responseBody;
            logCtx.statusCode = statusCode;
            logCtx.status = statusCode >= 200 && statusCode < 300 ? 'SUCCESS' : 'ERROR';
            logCtx.errorMessage = statusCode >= 200 && statusCode < 300
                ? null
                : 'Payment API returned non-success HTTP status.';
            logCtx.durationMs = durationMs;
            logCtx.correlationId = correlationId;
            logCtx.relatedOrderId = orderRecord.Id;

            IntegrationLogService.log(logCtx);

            if (statusCode >= 200 && statusCode < 300) {
                Map<String, Object> responseMap =
                    (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                String status = (String) responseMap.get('status');
                String message = (String) responseMap.get('message');
                String paymentId = (String) responseMap.get('paymentId');

                Boolean isApproved = status == 'SUCCESS';

                return new PaymentGatewayResult(
                    isApproved,
                    isApproved ? 'APPROVED' : 'DECLINED',
                    message,
                    paymentId,
                    statusCode,
                    responseBody
                );
            }

            return new PaymentGatewayResult(
                false,
                'DECLINED',
                'HTTP payment request failed.',
                null,
                statusCode,
                responseBody
            );

        } catch (System.CalloutException e) {
            Long durationMs = DateTime.now().getTime() - startTime;

            IntegrationLogContext logCtx = new IntegrationLogContext();
            logCtx.endpoint = ENDPOINT_PATH;
            logCtx.method = METHOD;
            logCtx.requestBody = requestBody;
            logCtx.status = 'TIMEOUT';
            logCtx.errorMessage = e.getMessage();
            logCtx.durationMs = durationMs;
            logCtx.correlationId = correlationId;
            logCtx.relatedOrderId = orderRecord.Id;

            IntegrationLogService.log(logCtx);

            throw e;

        } catch (Exception e) {
            Long durationMs = DateTime.now().getTime() - startTime;

            IntegrationLogContext logCtx = new IntegrationLogContext();
            logCtx.endpoint = ENDPOINT_PATH;
            logCtx.method = METHOD;
            logCtx.requestBody = requestBody;
            logCtx.status = 'ERROR';
            logCtx.errorMessage = e.getMessage();
            logCtx.durationMs = durationMs;
            logCtx.correlationId = correlationId;
            logCtx.relatedOrderId = orderRecord.Id;

            IntegrationLogService.log(logCtx);

            throw e;
        }
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
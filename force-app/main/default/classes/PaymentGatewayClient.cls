public with sharing class PaymentGatewayClient {

    private static final String ENDPOINT = 'callout:Proequip_Payment_API_OAuth/api/payments';
    private static final String ENDPOINT_PATH = '/api/payments';
    private static final String METHOD = 'POST';

    public static PaymentGatewayResult processPayment(Order__c orderRecord) {
        return processPayment(orderRecord, 0);
    }

    public static PaymentGatewayResult processPayment(Order__c orderRecord, Integer retryCount) {
        validateOrder(orderRecord);

        if (retryCount == null) {
            retryCount = 0;
        }
		
        String scenario = String.isBlank(orderRecord.Payment_Test_Scenario__c) ? 'SUCCESS' : orderRecord.Payment_Test_Scenario__c ;
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
            'scenario' => scenario
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
            logCtx.retryCount = retryCount;

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
            logCtx.retryCount = retryCount;

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
            logCtx.retryCount = retryCount;

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
/*
public with sharing class PaymentGatewayClient {

    private static final String ENDPOINT = 'callout:Proequip_Payment_API_OAuth/api/payments';
    private static final String ENDPOINT_PATH = '/api/payments';
    private static final String METHOD = 'POST';
    private static final Integer TIMEOUT_MS = 10000;
    private static final String DEFAULT_SCENARIO = 'SUCCESS';
    private static final String DEFAULT_CURRENCY = 'EUR';

    public static PaymentGatewayResult processPayment(Order__c orderRecord) {
        return processPayment(orderRecord, 0);
    }

    public static PaymentGatewayResult processPayment(Order__c orderRecord, Integer retryCount) {
        validateOrder(orderRecord);

        Integer currentRetryCount = normalizeRetryCount(retryCount);
        String scenario = resolveScenario(orderRecord);
        String correlationId = CorrelationIdGenerator.generate();
        String requestBody = buildRequestBody(orderRecord, scenario);
        HttpRequest req = buildRequest(requestBody, correlationId);

        Long startTime = DateTime.now().getTime();

        try {
            HttpResponse res = new Http().send(req);
            Long durationMs = calculateDuration(startTime);

            logHttpResponse(
                res,
                requestBody,
                durationMs,
                correlationId,
                orderRecord.Id,
                currentRetryCount
            );

            return buildGatewayResult(res);

        } catch (System.CalloutException e) {
            Long durationMs = calculateDuration(startTime);

            logTimeout(
                requestBody,
                e,
                durationMs,
                correlationId,
                orderRecord.Id,
                currentRetryCount
            );

            throw e;

        } catch (Exception e) {
            Long durationMs = calculateDuration(startTime);

            logUnexpectedError(
                requestBody,
                e,
                durationMs,
                correlationId,
                orderRecord.Id,
                currentRetryCount
            );

            throw e;
        }
    }

    private static HttpRequest buildRequest(String requestBody, String correlationId) {
        HttpRequest req = new HttpRequest();

        req.setEndpoint(ENDPOINT);
        req.setMethod(METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-Correlation-Id', correlationId);
        req.setTimeout(TIMEOUT_MS);
        req.setBody(requestBody);

        return req;
    }

    private static String buildRequestBody(Order__c orderRecord, String scenario) {
        Map<String, Object> payload = new Map<String, Object>{
            'orderId' => String.valueOf(orderRecord.Id),
            'accountId' => String.valueOf(orderRecord.Account__c),
            'amount' => orderRecord.Total_Amount__c,
            'currency' => DEFAULT_CURRENCY,
            'scenario' => scenario
        };

        return JSON.serialize(payload);
    }

    private static PaymentGatewayResult buildGatewayResult(HttpResponse res) {
        Integer statusCode = res.getStatusCode();
        String responseBody = res.getBody();

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
    }

    private static void logHttpResponse(
        HttpResponse res,
        String requestBody,
        Long durationMs,
        String correlationId,
        Id orderId,
        Integer retryCount
    ) {
        Integer statusCode = res.getStatusCode();
        String responseBody = res.getBody();
        Boolean isSuccessStatus = statusCode >= 200 && statusCode < 300;

        IntegrationLogContext logCtx = createBaseLogContext(
            requestBody,
            durationMs,
            correlationId,
            orderId,
            retryCount
        );

        logCtx.responseBody = responseBody;
        logCtx.statusCode = statusCode;
        logCtx.status = isSuccessStatus ? 'SUCCESS' : 'ERROR';
        logCtx.errorMessage = isSuccessStatus
            ? null
            : 'Payment API returned non-success HTTP status.';

        IntegrationLogService.log(logCtx);
    }

    private static void logTimeout(
        String requestBody,
        System.CalloutException e,
        Long durationMs,
        String correlationId,
        Id orderId,
        Integer retryCount
    ) {
        IntegrationLogContext logCtx = createBaseLogContext(
            requestBody,
            durationMs,
            correlationId,
            orderId,
            retryCount
        );

        logCtx.status = 'TIMEOUT';
        logCtx.errorMessage = e.getMessage();

        IntegrationLogService.log(logCtx);
    }

    private static void logUnexpectedError(
        String requestBody,
        Exception e,
        Long durationMs,
        String correlationId,
        Id orderId,
        Integer retryCount
    ) {
        IntegrationLogContext logCtx = createBaseLogContext(
            requestBody,
            durationMs,
            correlationId,
            orderId,
            retryCount
        );

        logCtx.status = 'ERROR';
        logCtx.errorMessage = e.getMessage();

        IntegrationLogService.log(logCtx);
    }

    private static IntegrationLogContext createBaseLogContext(
        String requestBody,
        Long durationMs,
        String correlationId,
        Id orderId,
        Integer retryCount
    ) {
        IntegrationLogContext logCtx = new IntegrationLogContext();

        logCtx.endpoint = ENDPOINT_PATH;
        logCtx.method = METHOD;
        logCtx.requestBody = requestBody;
        logCtx.durationMs = durationMs;
        logCtx.correlationId = correlationId;
        logCtx.relatedOrderId = orderId;
        logCtx.retryCount = retryCount;

        return logCtx;
    }

    private static String resolveScenario(Order__c orderRecord) {
        return String.isBlank(orderRecord.Payment_Test_Scenario__c)
            ? DEFAULT_SCENARIO
            : orderRecord.Payment_Test_Scenario__c;
    }

    private static Integer normalizeRetryCount(Integer retryCount) {
        return retryCount == null ? 0 : retryCount;
    }

    private static Long calculateDuration(Long startTime) {
        return DateTime.now().getTime() - startTime;
    }

    private static void validateOrder(Order__c orderRecord) {
        if (orderRecord == null) {
            throw new BusinessException('Order record is required for payment processing.');
        }

        if (orderRecord.Id == null) {
            throw new BusinessException('Order must be persisted before payment processing.');
        }
    }
}*/
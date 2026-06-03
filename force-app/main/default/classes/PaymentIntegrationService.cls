public with sharing class PaymentIntegrationService {

    public static void processPayment(Id orderId) {
        validateOrderId(orderId);

        Order__c orderRecord = OrderSelector.getById(orderId);

        try {
            PaymentGatewayResult gatewayResult =
                PaymentGatewayClient.processPayment(orderRecord);

            SystemLogService.logInfo(
                'PAYMENT_REQUEST',
                'PaymentIntegrationService.processPayment',
                'HTTP payment processing completed. Response received.',
                'Resolved',
                orderRecord.Id,
                null
            );

            applyGatewayResult(orderRecord, gatewayResult);

        } catch (BusinessException e) {
            handleTechnicalFailure(
                orderRecord,
                'Payment processing failed with business exception.',
                e
            );
            throw e;

        } catch (Exception e) {
            handleTechnicalFailure(
                orderRecord,
                'Unexpected error during HTTP payment processing.',
                e
            );
            throw e;
        }
    }

    public static void processPaymentWithRetry(Id orderId, Integer retryCount) {
        validateOrderId(orderId);

        if (retryCount == null) {
            retryCount = 0;
        }

        Order__c orderRecord = OrderSelector.getById(orderId);

        try {
            PaymentGatewayResult gatewayResult =
                PaymentGatewayClient.processPayment(orderRecord, retryCount);

            SystemLogService.logInfo(
                'PAYMENT_RETRY_SUCCESS',
                'PaymentIntegrationService.processPaymentWithRetry',
                'Retry payment succeeded.',
                'Resolved',
                orderRecord.Id,
                null
            );

            applyGatewayResult(orderRecord, gatewayResult);

        } catch (Exception e) {
            Boolean retryable = RetryPolicy.isRetryable(e);

            if (retryable && retryCount < RetryPolicy.getMaxRetries()) {
                IntegrationLogContext logCtx = new IntegrationLogContext();

                logCtx.status = 'RETRY_PENDING';
                logCtx.errorMessage =
                    'Retry scheduled. Attempt: ' + String.valueOf(retryCount + 1);
                logCtx.retryCount = retryCount + 1;
                logCtx.relatedOrderId = orderRecord.Id;

                IntegrationLogService.log(logCtx);

                System.enqueueJob(
                    new PaymentRetryQueueable(
                        orderId,
                        retryCount + 1
                    )
                );

                return;
            }

            IntegrationLogContext failedCtx = new IntegrationLogContext();

            failedCtx.status = 'FAILED_FINAL';
            failedCtx.errorMessage = 'Maximum retry attempts reached.';
            failedCtx.retryCount = retryCount;
            failedCtx.relatedOrderId = orderRecord.Id;

            IntegrationLogService.log(failedCtx);

           handleTechnicalFailure(
               orderRecord,
               'Retry mechanism failed.',
               e
			);

			return;
        }
    }

    private static void applyGatewayResult(Order__c orderRecord, PaymentGatewayResult gatewayResult) {
        validateOrderRecord(orderRecord);
        validateGatewayResult(gatewayResult);

        if (gatewayResult.isSuccess) {
            orderRecord.Status__c = 'Confirmed';
            orderRecord.Payment_Status__c = 'Success';
            update orderRecord;

            SystemLogService.logInfo(
                'PAYMENT_SUCCESS',
                'PaymentIntegrationService.applyGatewayResult',
                gatewayResult.message + ' HTTP status: ' + gatewayResult.httpStatusCode,
                'Resolved',
                orderRecord.Id,
                null
            );
            return;
        }

        orderRecord.Status__c = 'Payment Failed';
        orderRecord.Payment_Status__c = 'Failed';
        update orderRecord;

        SystemLogService.logWarn(
            'PAYMENT_FAILURE',
            'PaymentIntegrationService.applyGatewayResult',
            gatewayResult.message + ' HTTP status: ' + gatewayResult.httpStatusCode,
            'Open',
            orderRecord.Id,
            null
        );
    }

    private static void handleTechnicalFailure(Order__c orderRecord, String message, Exception e) {
        if (orderRecord != null) {
            orderRecord.Status__c = 'Payment Failed';
            orderRecord.Payment_Status__c = 'Failed';
            update orderRecord;
        }

        SystemLogService.logError(
            'PAYMENT_ERROR',
            'PaymentIntegrationService.processPayment',
            message,
            'Open',
            orderRecord != null ? orderRecord.Id : null,
            null,
            e
        );
    }

    private static void validateOrderId(Id orderId) {
        if (orderId == null) {
            throw new BusinessException('OrderId is required for payment processing.');
        }
    }

    private static void validateOrderRecord(Order__c orderRecord) {
        if (orderRecord == null) {
            throw new BusinessException('Order record is required for payment processing.');
        }
    }

    private static void validateGatewayResult(PaymentGatewayResult gatewayResult) {
        if (gatewayResult == null) {
            throw new BusinessException('Payment gateway result is required.');
        }
    }
}
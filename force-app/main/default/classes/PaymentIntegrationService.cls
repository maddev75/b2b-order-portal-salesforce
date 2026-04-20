public with sharing class PaymentIntegrationService {

    public static void processPayment(Id orderId) {
        validateOrderId(orderId);

        Order__c orderRecord = OrderSelector.getById(orderId);

        SystemLogService.logInfo(
            'PAYMENT_REQUEST',
            'PaymentIntegrationService.processPayment',
            'HTTP payment processing started.',
            'Open',
            orderRecord.Id,
            null
        );

        try {
            PaymentGatewayResult gatewayResult = PaymentGatewayClient.processPayment(orderRecord);

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

    private static void applyGatewayResult(Order__c orderRecord, PaymentGatewayResult gatewayResult) {
        validateOrderRecord(orderRecord);
        validateGatewayResult(gatewayResult);

        if (gatewayResult.isSuccess) {
            orderRecord.Payment_Status__c = 'Paid';
            update orderRecord;

            SystemLogService.logInfo(
                'PAYMENT_SUCCESS',
                'PaymentIntegrationService.applyGatewayResult',
                gatewayResult.message + ' HTTP status: ' + gatewayResult.httpStatusCode,
                'SUCCESS',
                orderRecord.Id,
                null
            );
            return;
        }

        orderRecord.Payment_Status__c = 'Open';
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
            orderRecord.Payment_Status__c = 'Open';
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
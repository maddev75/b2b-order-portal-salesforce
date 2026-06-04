public with sharing class PaymentRetryQueueable
implements Queueable, Database.AllowsCallouts {

    private Id orderId;
    private Integer retryCount;

    public PaymentRetryQueueable(Id orderId, Integer retryCount) {
        this.orderId = orderId;
        this.retryCount = retryCount;
    }

    public void execute(QueueableContext context) {

        PaymentIntegrationService.processPaymentWithRetry(
            orderId,
            retryCount
        );
    }
}
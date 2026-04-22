public with sharing class PaymentQueueable implements Queueable, Database.AllowsCallouts {

    private Id orderId;

    public PaymentQueueable(Id orderId) {
        this.orderId = orderId;
    }

    public void execute(QueueableContext context) {
        PaymentIntegrationService.processPayment(orderId);
    }
}
public class IntegrationLogContext {

    public String externalSystem;
    public String endpoint;
    public String method;
    public String requestBody;
    public String responseBody;
    public Integer statusCode;
    public String status;
    public String errorMessage;
    public Long durationMs;
    public String correlationId;
    public Integer retryCount;
    public Id relatedOrderId;
    public Id relatedPaymentId;

    public IntegrationLogContext() {
        this.externalSystem = 'Proequip Payment API';
        this.retryCount = 0;
    }
}
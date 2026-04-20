public class PaymentGatewayResult {
    public Boolean isSuccess;
    public String status;
    public String message;
    public String externalReference;
    public Integer httpStatusCode;
    public String rawResponse;

    public PaymentGatewayResult(
        Boolean isSuccess,
        String status,
        String message,
        String externalReference,
        Integer httpStatusCode,
        String rawResponse
    ) {
        this.isSuccess = isSuccess;
        this.status = status;
        this.message = message;
        this.externalReference = externalReference;
        this.httpStatusCode = httpStatusCode;
        this.rawResponse = rawResponse;
    }
}
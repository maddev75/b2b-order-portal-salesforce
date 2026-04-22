@IsTest
global class PaymentGatewayHttpExceptionMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        throw new CalloutException('Simulated callout exception');
    }
}
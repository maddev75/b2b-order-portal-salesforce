@IsTest
global class PaymentGatewayHttpMock implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;

    global PaymentGatewayHttpMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        return res;
    }
}
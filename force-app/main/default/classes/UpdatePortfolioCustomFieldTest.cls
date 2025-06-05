@isTest
public class UpdatePortfolioCustomFieldTest {

    // Mock for HTTP callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testUpdatePortfolioCustomFieldFlowEntryPoint() {
        // Insert fake Custom Metadata using Test Setup
        // PropertyWare_Setting__mdt testCreds = new PropertyWare_Setting__mdt(
        //     DeveloperName = 'PW_PPMG_Creds',
        //     MasterLabel = 'PW_PPMG_Creds',
        //     x_propertyware_client_id__c = 'test-client-id',
        //     x_propertyware_client_secret__c = 'test-secret',
        //     x_propertyware_system_id__c = 'test-system-id'
        // );
        // insert testCreds;

        // Insert test Portfolio record
        PW_Portfolio__c portfolio = new PW_Portfolio__c(
            Name = 'Test Portfolio',
            PW_Portfolio_Entity_ID__c = '123456789',
            PW_Org__c = 'Premier Property Management Group'
            // Customer_Service_Assignment__c = 'Demand chain'
        );
        insert portfolio;

        // Set callout mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Prepare flow input
        UpdatePortfolioCustomField.PortfolioInput input = new UpdatePortfolioCustomField.PortfolioInput();
        input.entityIdList = new List<String>{ portfolio.Id };

        // Call the flow-invocable method
        UpdatePortfolioCustomField.updateCustomField(new List<UpdatePortfolioCustomField.PortfolioInput>{ input });

        Test.stopTest(); // This executes the queueable
    }
}

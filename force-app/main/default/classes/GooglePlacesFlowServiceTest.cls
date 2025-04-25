@isTest
private class GooglePlacesFlowServiceTest {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"candidates":[{"place_id":"ChIJN1t_tDeuEmsRUsoyG83frY4"}],"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetPlaceIdFromAccount() {
        // Create a House__c record with address parts
        House__c house = new House__c(
            Name = 'Test House',
            Street_Address__c = '1600 Amphitheatre Parkway',
            City__c = 'Mountain View',
            State__c = 'TN',
            Zip_Code__c = '94043'
        );
        insert house;

        // Prepare input
        GooglePlacesFlowService.InputWrapper input = new GooglePlacesFlowService.InputWrapper();
        input.recordId = house.Id;

        List<GooglePlacesFlowService.InputWrapper> inputs = new List<GooglePlacesFlowService.InputWrapper> { input };

        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        GooglePlacesFlowService.getPlaceIdFromAccount(inputs);
        Test.stopTest();

        // Verify the Google_Place_ID__c was updated
        house = [SELECT Google_Place_ID__c FROM House__c WHERE Id = :house.Id];
        System.assertEquals('ChIJN1t_tDeuEmsRUsoyG83frY4', house.Google_Place_ID__c);
    }
}
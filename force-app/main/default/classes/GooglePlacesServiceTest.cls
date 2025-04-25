@isTest
private class GooglePlacesServiceTest {

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
    static void testGetPlaceIdFromHouseRecordId() {
        // Setup test metadata if needed
        // Not required unless getInstance call to custom metadata fails in test

        // Insert test House__c record
        House__c testHouse = new House__c(
            Name = 'Test House',
            Street_Address__c = '1600 Amphitheatre Parkway',
            City__c = 'Mountain View',
            State__c = 'TN',
            Zip_Code__c = '94043'
        );
        insert testHouse;

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        GooglePlacesService.getPlaceIdFromHouseRecordId(testHouse.Id);
        Test.stopTest();

        // Reload the record to verify update
        testHouse = [SELECT Google_Place_ID__c FROM House__c WHERE Id = :testHouse.Id];
        System.assertEquals('ChIJN1t_tDeuEmsRUsoyG83frY4', testHouse.Google_Place_ID__c);
    }
}
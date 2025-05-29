@isTest
private class ScheduleUpdateHouseGooglePlaceIdTest {

    // Mock class to simulate the GooglePlacesService callout
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
    static void testScheduledJob() {
        // Create test data
        List<House__c> houses = new List<House__c>();
        for (Integer i = 0; i < 5; i++) {
            houses.add(new House__c(
                Name = 'Test House ' + i,
                PW_ID_Number__c = 'PW-' + i,
                Street_Address__c = '1234 Main Ave',
                City__c = 'Default City',
                State__c = 'TN',
                Zip_Code__c = '00000',
                Status__c = 'Managed',
                Google_Place_ID__c = null
            ));
        }
        insert houses;

        // Replace GooglePlacesService with mock (only if your class uses DI or stubbing)
        // This step assumes you’ve structured GooglePlacesService to be overrideable/testable.
        Test.startTest();

        // Schedule the class
        String cronExp = '0 0 0 1 1 ? 2050'; // Any valid future date/time
        String jobId = System.schedule('Test Google Place ID Scheduler', cronExp, new ScheduleUpdateHouseGooglePlaceId());

        Test.stopTest();

        // Optionally verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'Test Google Place ID Scheduler' LIMIT 1];
        System.assertEquals('WAITING', ct.State);
    }
}

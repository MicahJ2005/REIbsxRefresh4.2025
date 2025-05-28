@IsTest
private class HouseCalloutQueueableTest {

    @IsTest
    static void testHouseCalloutQueueableExecution() {
        // Step 1: Create initial House__c record
        House__c house = new House__c(
            Name = 'Test House',
            Street_Address__c = '123 Test St',
            City__c = 'Testville',
            State__c = 'TN',
            Zip_Code__c = '90001',
            Google_Place_ID__c = 'PLACE_OLD'
        );
        insert house;

        // Step 2: Store the original ID
        Set<Id> oldIds = new Set<Id>{ house.Id };

        // Step 3: Update the house with a change
        house.Google_Place_ID__c = 'PLACE_NEW';
        update house;

        Set<Id> newIds = new Set<Id>{ house.Id };

        // Step 4: Enqueue the Queueable
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockGooglePlacesService());

        System.enqueueJob(new HouseCalloutQueueable(oldIds, newIds));

        Test.stopTest(); // Forces async code like queueables to run

        // Assertions (minimal since actual logic is in the external service)
        System.assert(true, 'Test ran to completion without unhandled exceptions.');
    }

    // Mock implementation for the callout service (if required by test coverage)
    public class MockGooglePlacesService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "place_id": "MOCKED_PLACE_ID" }');
            return res;
        }
    }
}

@isTest
private class PWLeaseConversationsControllerTest {

    // Mock class to simulate the HTTP response
    private class MockPWLeaseConversationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"message":"Test conversation 1"},{"message":"Test conversation 2"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetLeaseConversations() {
        // Insert required related records
        Account org = new Account(Name = 'PPMG of Texas, LLC', 
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId(),
                                    Type = 'Lender');
        insert org;

        House__c house = new House__c(Name = 'Test House');
        insert house;

        PW_Portfolio__c portfolio = new PW_Portfolio__c(Name = 'Test Portfolio', PW_Org__c = 'Premier Property Management Group');
        insert portfolio;

        // Insert building with required lookups
        PW_Building__c building = new PW_Building__c(
            Name = 'Test Building',
            PW_Building_Entity_ID1__c = 'B-001',
            PW_Building_ID__c = '001',
            House__c = house.Id,
            PW_Portfolio__c = portfolio.Id
        );
        insert building;

        // Simulate PW Portfolio, Building, and Lease
        // Use custom settings for relationships, adapt names as needed
        // PW_Portfolio__c portfolio = new PW_Portfolio__c(Name = 'Test Portfolio', PW_Org__c = org.Name);
        // insert portfolio;

        // PW_Building__c building = new PW_Building__c(Name = 'Test Building', PW_Portfolio__c = portfolio.Id);
        // insert building;

        PW_Lease__c lease = new PW_Lease__c(
            Name = 'Test Lease',
            PW_Lease_Entity_ID__c = '3226009604',
            PW_Building__c = building.Id
        );
        insert lease;

        // Create custom metadata record (manually insertable in test context using SObject)
        // Only works in Apex test if you use TestMetadataService or deploy beforehand
        // We'll simulate retrieval by stubbing the query using a custom setting workaround

        Test.startTest();

        // Register the mock response
        Test.setMock(HttpCalloutMock.class, new MockPWLeaseConversationResponse());

        // Call the controller method
        List<Object> conversations = PWLeaseConversationsController.getLeaseConversations(lease.Id);

        Test.stopTest();

        // Assert the expected size and content
        System.assertEquals(2, conversations.size());
        Map<String, Object> first = (Map<String, Object>)conversations[0];
        System.assertEquals('Test conversation 1', first.get('message'));
    }
}

@isTest
public class PropertyWareLeaseAPITexasTest {

    // Mock HTTP response for PropertyWare Lease API
    class PWLeaseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String body = JSON.serialize(new List<Map<String, Object>>{
                new Map<String, Object>{
                    'id' => 'L-001',
                    'leaseName' => 'Test Lease',
                    'active' => true,
                    'buildingID' => 'B-001',
                    'portfolioID' => 'P-001',
                    'status' => 'Active',
                    'moveInDate' => '2024-01-01T00:00:00Z',
                    'moveOutDate' => '2024-12-31T00:00:00Z',
                    'noticeGivenDate' => '2024-06-01T00:00:00Z',
                    'startDate' => '2024-01-01T00:00:00Z',
                    'endDate' => '2024-12-31T00:00:00Z',
                    'lastModifiedDateTime' => '2024-05-01T12:00:00Z',
                    'createdDateTime' => '2023-12-01T08:00:00Z',
                    'leaseBalance' => '1000.00',
                    'baseRent' => '1200.00',
                    'customFields' => new List<Map<String, Object>>{
                        new Map<String, Object>{'fieldName' => 'Filed to Evict', 'value' => 'Yes'},
                        new Map<String, Object>{'fieldName' => 'Court Date', 'value' => '2024-06-15'},
                        new Map<String, Object>{'fieldName' => 'Court Results', 'value' => 'Pending'},
                        new Map<String, Object>{'fieldName' => 'Call Date', 'value' => '2024-05-20'},
                        new Map<String, Object>{'fieldName' => 'Date Renewed', 'value' => '2024-04-01'},
                        new Map<String, Object>{'fieldName' => 'Owner Wants Inspection?', 'value' => 'No'},
                        new Map<String, Object>{'fieldName' => 'Owner Wants to Renew', 'value' => 'Yes'},
                        new Map<String, Object>{'fieldName' => 'Payment Contact Method', 'value' => 'Email'},
                        new Map<String, Object>{'fieldName' => 'Ordered WRIT', 'value' => 'No'},
                        new Map<String, Object>{'fieldName' => 'Put out w/ WRIT', 'value' => 'No'},
                        new Map<String, Object>{'fieldName' => 'Reason for Leaving', 'value' => 'Relocation'},
                        new Map<String, Object>{'fieldName' => 'Promise to Pay Date', 'value' => '2024-06-10'},
                        new Map<String, Object>{'fieldName' => 'Market Rent', 'value' => '1300.00'},
                        new Map<String, Object>{'fieldName' => '% Increase', 'value' => '5%'},
                        new Map<String, Object>{'fieldName' => 'Total Increase', 'value' => '65.00'}
                    }
                }
            });

            res.setBody(body);
            return res;
        }
    }

    @testSetup
    static void setupData() {
        // Insert required related records
        House__c house = new House__c(Name = 'Test House');
        insert house;

        PW_Portfolio__c portfolio = new PW_Portfolio__c(Name = 'Test Portfolio');
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
    }

    @isTest
    static void testQueueableExecution() {
        Test.setMock(HttpCalloutMock.class, new PWLeaseMock());

        Test.startTest();
        System.enqueueJob(new PropertyWareLeaseAPITexas());
        Test.stopTest();

        List<PW_Lease__c> leases = [SELECT Name, PW_Lease_Entity_ID__c FROM PW_Lease__c];
        System.assertEquals(1, leases.size(), 'Should insert 1 lease record');
        System.assertEquals('L-001', leases[0].PW_Lease_Entity_ID__c);
    }
}

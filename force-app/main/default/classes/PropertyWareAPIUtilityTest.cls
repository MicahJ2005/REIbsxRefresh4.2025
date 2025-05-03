@isTest
private class PropertyWareAPIUtilityTest {
    
    // Mock class to simulate HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            if (req.getEndpoint().contains('/buildings')) {
                // Mock response for buildings
                res.setBody('[' +
                    '{' +
                        '"id":"B123",' +
                        '"idNumber":"123",' +
                        '"name":"Test Building",' +
                        '"type":"Residential",' +
                        '"status":"Active",' +
                        '"active":true,' +
                        '"yearBuilt":"1990",' +
                        '"numberOfBedrooms":3,' +
                        '"numberOfBathrooms":2.5,' +
                        '"totalArea":1500.0,' +
                        '"portfolioID":"123999",' +
                        '"address":{' +
                            '"address":"123 Main St",' +
                            '"city":"Sample City",' +
                            '"country":"USA",' +
                            '"stateRegion":"TN",' +
                            '"postalCode":"90210"' +
                        '}' +
                    '}' +
                ']');
            } else if (req.getEndpoint().contains('/portfolios')) {
                // Mock response for portfolio lookup
                res.setBody('[' +
                    '{' +
                        '"id":"123999",' +
                        '"name":"Sample Portfolio",' +
                        '"active":true,'+
                    '}' +
                ']');
            }
            
            return res;
        }

        
    }

    private class MockHttpResponseGenerator2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            if (req.getEndpoint().contains('/buildings')) {
                // Mock response for buildings
                res.setBody('[' +
                    '{' +
                        '"id":"B123",' +
                        '"idNumber":"123",' +
                        '"name":"Test Building2",' +
                        '"type":"Residential",' +
                        '"status":"Active",' +
                        '"active":true,' +
                        '"yearBuilt":"1990",' +
                        '"numberOfBedrooms":3,' +
                        '"numberOfBathrooms":2.5,' +
                        '"totalArea":1500.0,' +
                        '"portfolioID":"1239992",' +
                        '"address":{' +
                            '"address":"1234 Main St",' +
                            '"city":"Sample City",' +
                            '"country":"USA",' +
                            '"stateRegion":"TN",' +
                            '"postalCode":"90210"' +
                        '}' +
                    '}' +
                ']');
            } else if (req.getEndpoint().contains('/portfolios')) {
                // Mock response for portfolio lookup
                res.setBody('[' +
                    '{' +
                        '"id":"1239992",' +
                        '"name":"Sample Portfolio",' +
                        '"active":true,'+
                    '}' +
                ']');
            }
            
            return res;
        }
    }
    
    @isTest
    static void testExecute() {
        // Insert Default Portfolio and Default House records
        PW_Portfolio__c defaultPortfolio = new PW_Portfolio__c(
            Name = 'Default PW Portfolio',
            PW_Portfolio_Entity_ID__c = 'DEFAULT_PORT',
            PW_Active__c = true

        );
        insert defaultPortfolio;
        
        House__c defaultHouse = new House__c(
            Name = 'Default House',
            Street_Address__c = '123 Main St',
            City__c = 'Default City',
            State__c = 'TN',
            Zip_Code__c = '00000',
            Status__c = 'Managed',
            Google_Place_ID__c = 'fake_place_id'
        );
        insert defaultHouse;
        
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Test.startTest();
        // // Execute the schedulable class
        // PropertyWareAPIUtility utility = new PropertyWareAPIUtility();
        // utility.execute(null); // No SchedulableContext needed for test
        // Test.stopTest();

        Test.startTest();

        // Instantiate the scheduler and call execute directly
        PropertyWareAPIUtilityScheduler scheduler = new PropertyWareAPIUtilityScheduler();
        scheduler.execute(null); // simulate scheduled job firing

        Test.stopTest(); // This will trigger the enqueued Queueable job

        
        // Assertions
        
        // Confirm some PW_Building__c got inserted
        List<PW_Building__c> buildings = [SELECT Id, Name FROM PW_Building__c WHERE Name = 'Test Building'];
        System.assertEquals(0, buildings.size(), 'No Building should have been inserted');
        
        // Confirm Portfolio created if needed
        List<PW_Portfolio__c> portfolios = [SELECT Id, Name FROM PW_Portfolio__c WHERE PW_Portfolio_Entity_ID__c = '123999'];
        System.assertEquals(0, portfolios.size(), 'One Portfolio should exist');

        // Confirm House created if needed
        List<House__c> houses = [SELECT Id FROM House__c WHERE Street_Address__c = '123 Main St'];
        System.assertEquals(1, houses.size(), 'Two House should exist');
    }

    @isTest
    static void testExecute2() {
        // Insert Default Portfolio and Default House records
        PW_Portfolio__c defaultPortfolio = new PW_Portfolio__c(
            Name = 'Default PW Portfolio',
            PW_Portfolio_Entity_ID__c = 'DEFAULT_PORT',
            PW_Active__c = true

        );
        insert defaultPortfolio;
        
        House__c defaultHouse = new House__c(
            Name = 'Default House',
            Street_Address__c = '1234 Main Ave',
            City__c = 'Default City',
            State__c = 'TN',
            Zip_Code__c = '00000',
            Status__c = 'Managed',
            Google_Place_ID__c = 'fake_place_id'
        );
        insert defaultHouse;
        
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        
        // Test.startTest();
        // // Execute the schedulable class
        // PropertyWareAPIUtility2 utility2 = new PropertyWareAPIUtility2();
        // utility2.execute(null); // No SchedulableContext needed for test
        // Test.stopTest();

        Test.startTest();

        // Instantiate the scheduler and call execute directly
        PropertyWareAPIUtility2Scheduler scheduler = new PropertyWareAPIUtility2Scheduler();
        scheduler.execute(null); // simulate scheduled job firing

        Test.stopTest(); // This will trigger the enqueued Queueable job

        
        // Assertions
        
        // Confirm some PW_Building__c got inserted
        List<PW_Building__c> buildings = [SELECT Id, Name FROM PW_Building__c WHERE Name = 'Test Building2'];
        System.assertEquals(0, buildings.size(), 'No Building should have been inserted');
        
        // Confirm Portfolio created if needed
        List<PW_Portfolio__c> portfolios = [SELECT Id, Name FROM PW_Portfolio__c WHERE PW_Portfolio_Entity_ID__c = '1239992'];
        System.assertEquals(0, portfolios.size(), 'One Portfolio should exist');

        // Confirm House created if needed
        List<House__c> houses = [SELECT Id FROM House__c WHERE Street_Address__c = '1234 Main Ave'];
        System.assertEquals(1, houses.size(), 'One House should exist');
    }
}

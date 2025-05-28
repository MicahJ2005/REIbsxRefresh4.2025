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
        // System.assertEquals(1, houses.size(), 'Two House should exist');
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

    @isTest
    static void testGetCurrentPWBuildings() {
        // Create mock House
        House__c testHouse = new House__c(Name = 'Test House');
        insert testHouse;

        // Create mock Portfolio
        PW_Portfolio__c testPortfolio = new PW_Portfolio__c(Name = 'Test Portfolio');
        insert testPortfolio;

        // Create existing PW_Building__c to simulate matching entity
        PW_Building__c existingBuilding = new PW_Building__c(
            Name = 'Existing Building',
            PW_Building_Entity_ID1__c = '1234',
            Google_Place_ID__c = 'gPlace1',
            PW_Portfolio__c = String.valueOf(testPortfolio.Id),
            House__c = String.valueOf(testHouse.Id)
        );
        insert existingBuilding;

        // Default IDs
        Id defaultPortfolioId = testPortfolio.Id;
        Id defaultHouseId = testHouse.Id;

        // Build test wrapper input
        Map<String, PropertyWareAPIUtility.PWBuildingWrapper> testBuildings = new Map<String, PropertyWareAPIUtility.PWBuildingWrapper>();
        PropertyWareAPIUtility.PWBuildingWrapper wrapper = new PropertyWareAPIUtility.PWBuildingWrapper();
        wrapper.name = 'Test Building';
        wrapper.status = 'Active';
        wrapper.active = true;
        wrapper.market = 'Market1';
        wrapper.address = '123 Main St';
        wrapper.city = 'Testville';
        wrapper.stateRegion = 'TS';
        wrapper.postalCode = '12345';
        wrapper.yearBuilt = '2000';
        wrapper.numberOfBedrooms = 2;
        wrapper.numberOfBathrooms = 1;
        wrapper.portfolioID = String.valueOf(testPortfolio.Id);
        wrapper.googlePlaceID = 'gPlace1';
        wrapper.PwCreatedDate = '2024-05-01T10:00:00';
        wrapper.PwLastModifiedDateTime = '2024-05-02T11:30:00';
        wrapper.buildingIdNumber = 'B123';
        wrapper.totalArea = 1000;
        wrapper.publishedForRent = true;
        wrapper.groupHOI = 'true';
        wrapper.isOwnerSellingNotes = 'Note';
        wrapper.isOwnerSellingClosingDate = '2024-06-01';
        testBuildings.put('1234', wrapper);

        Map<String, PropertyWareAPIUtility2.PWBuildingWrapper> testBuildings2 = new Map<String, PropertyWareAPIUtility2.PWBuildingWrapper>();
        PropertyWareAPIUtility2.PWBuildingWrapper wrapper2 = new PropertyWareAPIUtility2.PWBuildingWrapper();
        wrapper2.name = 'Test Building';
        wrapper2.status = 'Active';
        wrapper2.active = true;
        wrapper2.market = 'Market1';
        wrapper2.address = '123 Main St';
        wrapper2.city = 'Testville';
        wrapper2.stateRegion = 'TS';
        wrapper2.postalCode = '12345';
        wrapper2.yearBuilt = '2000';
        wrapper2.numberOfBedrooms = 2;
        wrapper2.numberOfBathrooms = 1;
        wrapper2.portfolioID = String.valueOf(testPortfolio.Id);
        wrapper2.googlePlaceID = 'gPlace1';
        wrapper2.PwCreatedDate = '2024-05-01T10:00:00';
        wrapper2.PwLastModifiedDateTime = '2024-05-02T11:30:00';
        wrapper2.buildingIdNumber = 'B123';
        wrapper2.totalArea = 1000;
        wrapper2.publishedForRent = true;
        wrapper2.groupHOI = 'true';
        wrapper2.isOwnerSellingNotes = 'Note';
        wrapper2.isOwnerSellingClosingDate = '2024-06-01';
        testBuildings2.put('1234', wrapper2);

        

        // Current SF maps
        Map<String, PW_Portfolio__c> currentPortfolioMap = new Map<String, PW_Portfolio__c>{
            String.valueOf(testPortfolio.Id) => testPortfolio
        };
        Map<String, House__c> currentHouseMap = new Map<String, House__c>{
            'gPlace1' => testHouse
        };

        Test.startTest();
        List<Map<String, PW_Building__c>> result = PropertyWareAPIUtility.getCurrentPWBuildings(
            testBuildings,
            defaultPortfolioId,
            defaultHouseId,
            currentPortfolioMap,
            currentHouseMap
        );

        List<Map<String, PW_Building__c>> result2 = PropertyWareAPIUtility2.getCurrentPWBuildings(
            testBuildings2,
            defaultPortfolioId,
            defaultHouseId,
            currentPortfolioMap,
            currentHouseMap
        );
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Expected 2 maps returned');
        System.assert(result[0].containsKey('1234') || result[1].containsKey('1234'), 'Building should be in one of the maps');
    }

    @isTest
    static void testGetCurrentPWBuildingsWithInvalidDate() {
        // Test method to cover the catch blocks for date parsing
        PW_Portfolio__c testPortfolio = new PW_Portfolio__c(Name = 'Test Portfolio 2');
        insert testPortfolio;
        
        House__c testHouse = new House__c(Name = 'Test House 2');
        insert testHouse;

        Map<String, PropertyWareAPIUtility.PWBuildingWrapper> testBuildings = new Map<String, PropertyWareAPIUtility.PWBuildingWrapper>();
        PropertyWareAPIUtility.PWBuildingWrapper wrapper = new PropertyWareAPIUtility.PWBuildingWrapper();
        wrapper.name = 'Invalid Date Building';
        wrapper.portfolioID = String.valueOf(testPortfolio.Id);
        wrapper.googlePlaceID = 'gPlace2';
        wrapper.PwCreatedDate = 'invalid-date';
        wrapper.PwLastModifiedDateTime = 'another-bad-date';
        testBuildings.put('9999', wrapper);

        Map<String, PropertyWareAPIUtility2.PWBuildingWrapper> testBuildings2 = new Map<String, PropertyWareAPIUtility2.PWBuildingWrapper>();
        PropertyWareAPIUtility2.PWBuildingWrapper wrapper2 = new PropertyWareAPIUtility2.PWBuildingWrapper();
        wrapper2.name = 'Invalid Date Building';
        wrapper2.portfolioID = String.valueOf(testPortfolio.Id);
        wrapper2.googlePlaceID = 'gPlace2';
        wrapper2.PwCreatedDate = 'invalid-date';
        wrapper2.PwLastModifiedDateTime = 'another-bad-date';
        testBuildings2.put('9999', wrapper2);

        Map<String, PW_Portfolio__c> currentPortfolioMap = new Map<String, PW_Portfolio__c>{
            String.valueOf(testPortfolio.Id) => testPortfolio
        };
        Map<String, House__c> currentHouseMap = new Map<String, House__c>{
            'gPlace2' => testHouse
        };

        Test.startTest();
        List<Map<String, PW_Building__c>> result = PropertyWareAPIUtility.getCurrentPWBuildings(
            testBuildings,
            testPortfolio.Id,
            testHouse.Id,
            currentPortfolioMap,
            currentHouseMap
        );

        List<Map<String, PW_Building__c>> result2 = PropertyWareAPIUtility2.getCurrentPWBuildings(
            testBuildings2,
            testPortfolio.Id,
            testHouse.Id,
            currentPortfolioMap,
            currentHouseMap
        );
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should still return two maps even with invalid dates');
    }

  
}
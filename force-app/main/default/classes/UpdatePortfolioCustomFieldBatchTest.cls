@isTest
private class UpdatePortfolioCustomFieldBatchTest {

    @isTest
    static void testBatchWithFormulaFieldDependency() {
        // Create Customer Service Assignment User
        User csrUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Alias = 'jdoe',
            Email = 'jdoe@example.com',
            Username = 'jdoe' + DateTime.now().getTime() + '@test.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            // Full_Name__c = 'John Doe'
        );
        insert csrUser;

        // Create Investor Owner
        Account investorOwner = new Account(
            Name = 'Investor Owner A',
            Type = 'Lender',
            Customer_Service_Assignment__c = csrUser.Id
        );
        insert investorOwner;

        // Create test portfolios that reference investorOwner
        List<PW_Portfolio__c> testPortfolios = new List<PW_Portfolio__c>();

        for (Integer i = 0; i < 5; i++) {
            testPortfolios.add(new PW_Portfolio__c(
                Name = 'Test Portfolio ' + i,
                PW_Portfolio_Entity_ID__c = 'Entity-' + i,
                PW_Batch_Synced__c = false,
                Investor_Owner__c = investorOwner.Id,
                PW_Org__c = 'PPMG of Texas, LLC'
            ));
        }
        insert testPortfolios;

        Test.startTest();
        Database.executeBatch(new UpdatePortfolioCustomFieldBatch());
        Test.stopTest();

        // Basic assert that records still exist
        List<PW_Portfolio__c> portfolios = [
            SELECT Id FROM PW_Portfolio__c WHERE PW_Batch_Synced__c = false
        ];
        System.assertEquals(5, portfolios.size(), 'Expected 5 eligible portfolio records');
    }
}


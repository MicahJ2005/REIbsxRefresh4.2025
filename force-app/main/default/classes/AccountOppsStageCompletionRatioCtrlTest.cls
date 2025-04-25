@isTest
public class AccountOppsStageCompletionRatioCtrlTest {
    
    @testSetup static void test_data() {
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        List<Account> accList = new List<Account>();
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId(),
                Name = 'Test Account',
                Vendor_Email__c = 'test2@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Agent/Wholesaler'                
            )
        );
        insert accList;
        
        List<Contact> listCon = new List<Contact>();
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id,
                Is_Primary__c = TRUE                
            )
        );
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test2',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id
            )
        );
        Insert listCon;
        List<Assessment__c> asmtList = new List<Assessment__c>();
        // 0
        asmtList.add(
            new Assessment__c(
                Name = 'Asmt-0',
                Market__c = 'MEM',
                Bedrooms__c = '2',
                Bathrooms__c = '2',
                Car_Storage_Parking__c = '2GD',
                Year_Built__c = '1962',
                Square_Ft__c = 100,
                Status__c = 'Completed'
            )
        );
        insert asmtList;
        
        List<House__c> houseList = new List<House__c>();
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        houseList.add(
            new House__c(
                Name = 'Test House1',
                City__c = 'Test City',
                State__c = 'OK',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        houseList.add(
            new House__c(
                Name = 'Test House2',
                City__c = 'Test City',
                State__c = 'MO',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        insert houseList;
        
        ID RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        ID buyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        List<opportunity> oppList = new List<Opportunity>();
        
        // 0
        oppList.add(
            new opportunity(
                Name = 'Opp 0',
                RecordTypeId = RecordTypeId,
                //Lender_Name__c = listCon[0].Id,
                //Lender_Approval__c = 'Y',
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_Offer__c = 200,                
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                LeadSource = 'WEB',
                AccountId = accList[0].id
            )
        );
        
        // 1
        oppList.add(
            new opportunity(
                Name = 'Opp 1',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_Offer__c = 200,
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
                
            )
        );
        
        // 2
        oppList.add(
            new opportunity(
                Name = 'Opp 2',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
            )
        );
        
        // 3
        oppList.add(
            new opportunity(
                Name = 'Opp 3',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
            )
        );
        
        
        // 4
        oppList.add(
            new opportunity(
                Name = 'Opp 4',
                RecordTypeId = RecordTypeId,
                Initial_Offer__c = 200,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
                
            )
        );
        
        // 5
        oppList.add(
            new opportunity(
                Name = 'Opp 5',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Initial_List_Price__c = 200,
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
            )
        );
        
        // 6
        oppList.add(
            new opportunity(
                Name = 'Opp 6',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Initial_Offer__c = 200,
                Car_Storage__c = '1GD',
                Initial_List_Price__c = 200,
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                AccountId = accList[0].id
            )
        );
        
        // 7
        oppList.add(
            new opportunity(
                Name = 'Opp 7',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 8
        oppList.add(
            new opportunity(
                Name = 'Opp 8',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Initial_Offer__c = 200,
                Bedrooms__c = '1',
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 9
        oppList.add(
            new opportunity(
                Name = 'Opp 9',
                RecordTypeId = RecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id
            )
        );
        
        // 10
        oppList.add(
            new opportunity(
                Name = 'Opp 9',
                RecordTypeId = buyRecordTypeId,
                CloseDate = date.today(),
                House__c = houseList[0].id,
                StageName = 'Purchased',
                Assessment__c = asmtList[0].id,
                Bathrooms__c = '1',
                Bedrooms__c = '1',
                Initial_Offer__c = 200,
                Square_Ft__c = 200,
                Car_Storage__c = '1GD',
                Year_Built__c = '2010',
                Appraised__c = 2000,
                Loan_Type__c = 'CV',
                Market__c = 'MEM',
                Info_Source__c = 'MLS',
                Initial_List_Price__c = 200,
                AccountId = accList[0].id,
                LeadSource = 'Other',
                Listing_Date__c = date.today()
            )
        );
        
        insert oppList;
    }
    
    @isTest 
    static void test_method() {
        Test.startTest();
        List<Account> accList = [SELECT Id FROM Account];
        AccountOppsStageCompletionRatioCtrl.getRelatedOpportunities(accList[0].Id);
        Test.stopTest();
    }
}
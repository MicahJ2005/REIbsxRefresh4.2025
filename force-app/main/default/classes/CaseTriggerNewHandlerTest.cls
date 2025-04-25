/**
    Name        : CaseTriggerNewHandlerTest
    Date        : Jan 4, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : This test class is used for code coverage of CaseTriggerNewHandler.
**/
@isTest
private class CaseTriggerNewHandlerTest{
    @testSetup 
    static void setup() {
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
        Account accInvestor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId(), '');
        accInvestor.Name = 'Test Cmentor';
        insert accInvestor;
        
        Account accInvestor2 = TestDataFactory.createAccount('Investor acc 2', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId(), '');
        accInvestor2.Name = 'Test Cmentor 2';
        insert accInvestor2;
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        opp.Name = 'Test Property';
        opp.AccountId = accInvestor.Id;
        opp.StageName = 'Pre-Qual';
        opp.CloseDate = System.today();
        opp.Closing_Date__c = System.today();
        insert opp;
        
        Contact conInvestor = TestDataFactory.createContact('Investor', 'Tester', '9879654321', 'testInvestorsf@tester.com', accInvestor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        insert conInvestor;
        
        House__c house = TestDataFactory.createHouse('Test Property', 'Test Property', 'Test Streeet', 'Memphis', 'TN', '39876', 'US');
        house.Investor__c = accInvestor.Id;
        insert house;
        
        Account acc = TestDataFactory.createAccount('Owner acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resident').getRecordTypeId(), '');
        insert acc;
        
        Opportunity opp2 = new Opportunity();
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        opp2.Name = 'Test Property';
        opp2.AccountId = acc.Id;
        opp2.StageName = 'Pre-Qual';
        opp2.CloseDate = System.today();
        opp2.Closing_Date__c = System.today();
        insert opp2;
        
        Opportunity opp3 = new Opportunity();
        opp3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        opp3.Name = 'Test Property';
        opp3.AccountId = acc.Id;
        opp3.StageName = 'Pre-Qual';
        opp3.CloseDate = System.today();
        opp3.Closing_Date__c = System.today();
        insert opp3;
        
        Contact con = TestDataFactory.createContact('Test', 'Tester', '9879654321', 'testsf@tester.com', acc.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resident').getRecordTypeId()
        );
        insert con;
        
        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId(), 'Open', 
            con.Id, house.Id, 'Test desc.', '9998887878', System.now(), false, System.now().addMonths(1), categoryEntries[0].getValue()
        );
        insert cs;
    }
    
    /*
    @isTest
    static void testMethod1(){        
        Case cs = [SELECT Id, RecordTypeId, Property__c, Status, ClosedDate FROM Case LIMIT 1];
        cs.Status = 'Create Project';
        update cs;
        
    }
	*/
    @isTest
    static void testMethod2(){
        List<House__c> houseList = [SELECT id, Name FROM House__c];
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        cs.Property__c = houseList[0].Id;
        insert cs;
    }
    
    @isTest
    static void testMethod3(){
        List<Account> accList = [SELECT Id FROM Account];
        Case cs = [SELECT Id, Investor__c, RecordTypeId, Property__c, Status, ClosedDate FROM Case LIMIT 1];
        cs.Investor__c = accList[2].Id;
        update cs;      
    }
	
}
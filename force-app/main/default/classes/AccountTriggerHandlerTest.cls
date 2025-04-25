/**
Name        : AccountTriggerHandlerTest
Date        : 
Author      : Shweta Fulara(Cmentor)
Description : This test class is used for coverage of AccountTriggerHandler.
**/
@isTest(seeAllData=True)
private class AccountTriggerHandlerTest{
    
    @isTest
    static void testMethod1() {
        
        /*Account accOwner = TestDataFactory.createAccount('Owner acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccOwnerRecType).getRecordTypeId(), 'Customer and Vendor');
insert accOwner;
*/
        
        Account accVendor = TestDataFactory.createAccount('Vendor acc',Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId(), 'Customer and Vendor');
        accVendor.Billing_Email__c = 'test@abc1.com';
        accVendor.BillingCity = 'Testing1';
        accVendor.BillingPostalCode = '12345';
        accVendor.BillingStreet = 'Test streeet1';
        accVendor.Maint_Category_1__c = 'Cages';
        accVendor.Category_1__c = 'Cages';
        accVendor.BillingState = 'test state1';
        accVendor.Bank_Name__c = 'Test Bank1';
        accVendor.Routing_Number__c = '123456781';
        accVendor.Account_Number__c = '1234567654321';
        accVendor.License__c = 'ABC123341';
        accVendor.Account_Type__c = 'Savings';
        accVendor.AccountUpdateFromPortal__c  = 'YES';
        insert accVendor;     
        system.debug('accVendor'+accVendor);
        accVendor.Market__c = 'MEM';
        accVendor.Approval_Status__c = 'Approved';
        update accVendor;
        
        accVendor.Market__c = 'MEM';
        accVendor.Approval_Status__c = 'Rejected';
        accVendor.Billing_Email__c = 'test@abc.com';
        accVendor.BillingCity = 'Testing';
        accVendor.BillingPostalCode = '1234';
        accVendor.BillingStreet = 'Test streeet';
        accVendor.Maint_Category_1__c = 'Cages';
        accVendor.Category_1__c = 'Cages';
        accVendor.BillingState = 'test state';
        accVendor.Bank_Name__c = 'Test Bank';
        accVendor.Routing_Number__c = '12345678';
        accVendor.Account_Number__c = '123456765432';
        accVendor.License__c = 'ABC12334';
        accVendor.Account_Type__c = 'Savings';
        accVendor.AccountUpdateFromPortal__c  = 'YES';
        update accVendor;
        
        
        AccountHistory [] ah =  [Select AccountId,createdDate,Field, OldValue, NewValue from AccountHistory where AccountId = :accVendor.Id];
        system.debug('Ah'+ah);
        
        /*
List<Account> accList = [SELECT Id, Name FROM Account];
List<AcctSeed__Accounting_Variable__c> accVariableList = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c='GL Account Variable 2'];
System.assertEquals(accList[0].Name, accVariableList[0].Name);
*/
    }
    
    @isTest
    public static void testMethod2(){
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId();
        acc.Name = 'Test Account';
        acc.Type = 'Lender';
        acc.Market__c = 'MEM';
        insert acc;
    }
    
    @isTest
    public static void testMethod3(){
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        acc.Name = 'Test Account';
        acc.Type = 'Lender';
        acc.Market__c = 'MEM';
        acc.AccountUpdateFromPortal__c  = 'YES';
        insert acc;
        
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
        insert houseList;
        
        List<Project__c> projectList = new List<Project__c>();
        // 0
        projectList.add(
            new Project__c(
                House__c = houseList[0].id,
                Pay_Account__c = 'New MEM'
            )
        );
        
        insert projectList;
        
        List<opportunity> oppList = new List<Opportunity>();

        oppList.add(
            new opportunity(
                Name = 'Opp 0',
                AccountId = acc.Id,
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor').getRecordTypeId(),
                Lender_Approval__c = 'N',
                CloseDate = date.today(),
                StageName = 'Pre-Qual',
                Project__c = projectList[0].Id,
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
                House_Number__c = 1
            )
        );
        
        insert oppList;
        
        oppList[0].StageName = 'Closed - Investor';
        update oppList[0];
        System.debug('House Vendor '+houseList[0]);
    }
    
}
@isTest
public class ChildAccountsWithPropertyOwnerCtrlTest {
    
    
    @testSetup 
    static void testdata() {
        
        Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        Id investorOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Owner').getRecordTypeId();
        
        List<Account> accList =  new List<Account>();
        // 0
        accList.add(
            new Account(
                Name = 'Child Account',
                RecordTypeId = investorOwnerRecordTypeId
            )
        );
        Insert accList;
        
        // Insert Child Account
        Account acc = new Account();
        acc.Name = 'Parent Account';
        acc.RecordTypeId = ownerRecordTypeId;
        acc.ParentId = accList[0].id;
        Insert acc;
        
        // Insert House
        House__c ho = new House__c();
        Insert ho;
        
        
        // Insert Property Owner
        Property_Owner__c po = new Property_Owner__c();
        po.Status__c = 'Active';
        po.Account__c = acc.id;
        po.Property__c = ho.id;
        Insert po;
    }
    
    // Test Methods Begins From Here
    
    @isTest
    static void test_getChildAccountsWithPropertyOwner(){
        
        Test.startTest();
        
        List<Account> accList = [SELECT Id,ParentId FROM Account WHERE Name =: 'Parent Account'];
        ChildAccountsWithPropertyOwnerCtrl.getChildAccountsWithPropertyOwner(accList[0].ParentId, 'Active');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void test_getChildAccountsWithPropertyOwner_1(){
        
        Test.startTest();
        
        List<Account> accList = [SELECT Id,ParentId FROM Account WHERE Name =: 'Parent Account'];
        ChildAccountsWithPropertyOwnerCtrl.getChildAccountsWithPropertyOwner(accList[0].ParentId, 'All');
        
        Test.stopTest();
        
    }
    
}
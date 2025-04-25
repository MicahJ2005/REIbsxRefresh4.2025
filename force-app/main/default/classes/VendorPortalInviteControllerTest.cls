@isTest
private class VendorPortalInviteControllerTest {
    @isTest static void method1(){
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        a.Name = 'Test';
        a.Market__c = 'MEM';
        a.Status__c = 'Active';
        a.Primary_Contact_Email__c = 'test@gmail.com';
        insert a;
        Account a1 = new Account();
        a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        a1.Name = 'Test1';
        a1.Market__c = 'MEM';
        a1.Status__c = 'Active';
        a1.Primary_Contact_Email__c = 'test1@gmail.com';
        insert a1;
        accList.add(a);
        accList.add(a1);
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.Is_Primary__c = true;
        con.AccountId = a.Id;
        insert con;
        Contact con1 = new Contact();
        con1.LastName = 'Test Contact1';
        con1.AccountId = a1.Id;
        insert con1;
        
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(accList);
        stdSetController.setSelected(accList);
        VendorPortalInviteController cMethod = new VendorPortalInviteController(stdSetController);
        cMethod.inviteAccount();
        Test.stopTest();
    }
       
}
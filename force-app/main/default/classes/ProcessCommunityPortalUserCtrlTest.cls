@isTest
public class ProcessCommunityPortalUserCtrlTest {
         
    @isTest
    static void testMethod1() {
        Id accountVendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Account acc = new Account(Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Market__c = 'MEM', Status__c ='Active', Primary_Contact_Email__c = 'test@gmail.com',
                                  recordtypeId = accountVendorRecordTypeId );
        insert acc;
        
        Id contactVendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Contact con = new Contact(firstName = 'Test',lastName = 'Test', accountId = acc.Id, Is_Primary__c = true, Email = 'testcontact112@gmail.com', recordtypeId = contactVendorRecordTypeId);
        insert con;
        
        Test.startTest();
        ProcessCommunityPortalUserCtrl.processUser(con.Id);
        Test.stopTest();
    
    }
    
}
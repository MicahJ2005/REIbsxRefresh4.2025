/**
Name        : VendorDocumentExpiryReminderTest
Date        : Aug 01, 2019
Author      : Shweta Fulara
Description : This test class is used to cover VendorDocumentExpiryReminder batch class.
**/
@isTest
private class VendorDocumentExpiryReminderTest {
         
    @isTest
    static void testMethod1() {
        //Insert test account where record type vendor
        Account acc = new Account(Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                                  recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId()      
                                  );
        insert acc;
        //Insert list of contentversion
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(new ContentVersion(Title='Test', PathOnClient ='testing',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(45)
                                              ));
        cvList.add(new ContentVersion(Title='Test2', PathOnClient ='testing2',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body5'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(15)
                                              ));
        cvList.add(new ContentVersion(Title='Test3', PathOnClient ='testing3',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body2'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(30)
                                              ));
        cvList.add(new ContentVersion(Title='Test6', PathOnClient ='testing6',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body3'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(15)
                                              ));
        cvList.add(new ContentVersion(Title='Test5', PathOnClient ='testing5',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body4'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(30)
                                              ));                                              
        cvList.add(new ContentVersion(Title='Test4', PathOnClient ='testing4',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                               FirstPublishLocationId=acc.Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(45)
                                              ));
        insert cvList;
            
        Test.startTest();
        //Execute batch class
        VendorDocumentExpiryReminder b = new VendorDocumentExpiryReminder();
        database.executeBatch(b);
        Test.stopTest();
    
    }
    
}
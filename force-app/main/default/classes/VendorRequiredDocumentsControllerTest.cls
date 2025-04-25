/**
Name        : VendorRequiredDocumentsControllerTest
Date        : Aug 01, 2019
Author      : Shweta Fulara
Description : This test class is used to cover VendorRequiredDocumentsController batch class.
**/
@isTest
private class VendorRequiredDocumentsControllerTest {
         
    @isTest
    static void testMethod1() {
        id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        List<Account> accList = new List<Account>();
        //Insert test account where record type vendor
        
        // 0
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Category_1__c = 'Appliances', Market__c = 'MEM', type = 'Rehab & Maintenance',Maint_Category_1__c = 'Appliances',
                recordtypeId = rt    
            )
        );
        
        // 1
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Category_1__c = 'Appliances', Market__c = 'DFW', type = 'Rehab & Maintenance',Maint_Category_1__c = 'Appliances',
                recordtypeId = rt    
            )
        );
        
        // 2
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Category_1__c = 'Electrical',
                recordtypeId = rt    
            )
        );
        
        // 3
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Category_1__c = 'Engineer',
                recordtypeId = rt    
            )
        );
        
        // 4
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Category_1__c = 'Engineer',Market__c = 'MEM',type = 'Rehab & Maintenance',Maint_Category_1__c = 'Appliances',
                recordtypeId = rt    
            )
        );
        
        // 5
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Market__c = 'MEM',type = 'Maintenance',Maint_Category_1__c = 'Appliances',
                recordtypeId = rt    
            )
        );
        
        // 6
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Market__c = 'DFW',type = 'Maintenance',Maint_Category_1__c = 'Appliances',
                recordtypeId = rt    
            )
        );
        
        // 7
        accList.add(
            new Account(
                Name ='Test acc',Vendor_Email__c = 'test@gmail.com', Primary_Contact_Email__c = 'test@gmail.com',
                Market__c = 'DFW',type = 'Maintenance',Maint_Category_1__c = 'HVAC',
                recordtypeId = rt    
            )
        );
        insert accList;
        //Insert list of contentversion
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(new ContentVersion(Title='Test', PathOnClient ='testing',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body'),
                                               FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(45)
                                              ));
        cvList.add(new ContentVersion(Title='Test2', PathOnClient ='testing2',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                               FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(15)
                                              ));
        cvList.add(new ContentVersion(Title='Test3', PathOnClient ='testing3',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                               FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(30)
                                              ));
        
        cvList.add(new ContentVersion(Title='Test4', PathOnClient ='testing4',VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body1'),
                                               FirstPublishLocationId=accList[0].Id,Attachment_Type__c = 'Certificate of Insurance - General Liability',
                                               Expiration_Date__c = Date.today().addDays(45)
                                              ));
        insert cvList;
            
        Test.startTest();
        
        VendorRequiredDocumentsController.getAccount(accList[0].id);
        VendorRequiredDocumentsController.getConVersionList(accList[0].id);
        VendorRequiredDocumentsController.updateFiles(cvList);
        VendorRequiredDocumentsController.getConVersionList(accList[1].id);
        VendorRequiredDocumentsController.getConVersionList(accList[2].id);
        VendorRequiredDocumentsController.getConVersionList(accList[3].id);
        VendorRequiredDocumentsController.getConVersionList(accList[4].id);
        VendorRequiredDocumentsController.getConVersionList(accList[5].id);
        VendorRequiredDocumentsController.getConVersionList(accList[6].id);
        VendorRequiredDocumentsController.getConVersionList(accList[7].id);
        Test.stopTest();
    
    }
    
}
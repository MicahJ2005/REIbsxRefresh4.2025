@isTest
private class VendorDocumentExpiredBatchTest {
    @isTest static void method(){
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            Status__c = 'Uploaded',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true,
            Expiration_Date__c = Date.today()
        );
        insert cv;
        ContentVersion cv1 = new ContentVersion(
            Title = 'Test 1',
            PathOnClient = 'Test.jpg',
            Status__c = 'Uploaded',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true,
            Expiration_Date__c = Date.today()
        );
        insert cv1;
        
        
        Account acc = new Account (Name = 'Test Account', 
                                   Status__c = 'Inactive',
                                   RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.AccVendorRecType).getRecordTypeId());
        insert acc;
        
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentVersion contentVersionSelect1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=acc.id;  
        contentlink.ShareType= 'V';               
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentDocumentLink contentlink1 =new ContentDocumentLink();
        contentlink1.LinkedEntityId=acc.id;  
        contentlink1.ShareType= 'V';               
        contentlink1.ContentDocumentId=documents[1].Id;
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        
        VendorDocumentExpiredBatch bMethod = new VendorDocumentExpiredBatch();
        Database.executeBatch(bMethod);
    }
}
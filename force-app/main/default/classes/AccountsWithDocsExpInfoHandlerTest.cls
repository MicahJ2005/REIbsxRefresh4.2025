@isTest
public class AccountsWithDocsExpInfoHandlerTest {
    
    @testSetup static void test_Data() {
        
        Account accRecord = new Account(
            Name = 'The Pepsico Company',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Field Service').getRecordTypeId()
        );
        
        insert accRecord;
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(
            new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Attachment_Type__c = 'Driver’s License/Photo Id',
                Expiration_Date__c = date.today()
            )
        );
        cvList.add(
            new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Attachment_Type__c = 'License',
                Expiration_Date__c = date.today().addDays(23)
            )
        );
        cvList.add(
            new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Attachment_Type__c = 'Certificate of Insurance - General Liability',
                Expiration_Date__c = date.today().addDays(43)
            )
        );
        insert cvList;
        
        List<ContentVersion> converList = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id in : cvList];
        for(ContentVersion cv : converList){
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = accRecord.id;
            contentlink.contentdocumentid = cv.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
        }
    }
    
    @isTest static void test_getaccountsWithDocsExpirationInfo(){
        AccountsWithDocsExpirationInfoHandler.getaccountsWithDocsExpirationInfo();
    }
}
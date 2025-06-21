@isTest
public class OpportunityDocumentCtrlTest {
   
    @testSetup
    static void setup() {
        // Create Account
        Account acc = new Account(Name='Test Account', Type = 'Custodian');
        insert acc;

        // Create Contact
        Contact con = new Contact(FirstName='John', LastName='Doe', Email='john.doe@example.com', AccountId=acc.Id);
        insert con;

        // Create User
        User u = [SELECT Id FROM User WHERE Profile.Name='System Administrator' LIMIT 1];

        // Create Title Company (Contact)
        Contact titleCompany = new Contact(FirstName='Title', LastName='Attorney', Email='title.attorney@example.com', AccountId=acc.Id);
        insert titleCompany;

        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(10),
            Market__c='MEM',
            Title_Company_Attorney__c=titleCompany.Id,
            OwnerId=u.Id,
            Source_Contact__c=con.Id,
            LeadSource = '	BiggerPockets',
            AccountId=acc.Id
        );
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Buy').getRecordTypeId();
        // opp.Name = 'Opp 0';
        opp.Title_Verification_Email__c = TRUE;
        // opp.CloseDate = date.today();
        // opp.StageName = 'RecordTypeId = RecordTypeId';
        opp.Bathrooms__c = '1';
        opp.Bedrooms__c = '1';
        opp.Square_Ft__c = 200;
        opp.Car_Storage__c = '1GD';
        opp.Year_Built__c = '2010';
        opp.Appraised__c = 2000;
        opp.Loan_Type__c = 'CV';
        // opp.Market__c = 'MEM';
        opp.Initial_Offer__c = 200;
        opp.Initial_List_Price__c = 200;
        opp.Info_Source__c = 'MLS';
        // opp.LeadSource = 'Client Referral';
        opp.Listing_Date__c = System.today() - 10;
        insert opp;

        // Create Custom Metadata record
        // You can't insert Metadata via Apex, so make sure one exists in org with Label = 'test@example.com'

        // Create ContentVersion and attach to ContentDocument
        ContentVersion cv = new ContentVersion(
            Title='TestDoc',
            PathOnClient='TestDoc.pdf',
            VersionData=Blob.valueOf('Test content')
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId=cv.ContentDocumentId,
            LinkedEntityId=opp.Id,
            ShareType='V'
        );
        insert cdl;
    }

    @isTest
    static void testUpdateFileType() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        Opportunity updatedOpp = OpportunityDocumentCtrl.updateFileType(
            'TestDoc.pdf',
            cv.ContentDocumentId,
            'Contract_Document_1',
            opp.Id
        );
        Test.stopTest();

        System.assertEquals('TestDoc.pdf', updatedOpp.Contract_Document_1__c);
    }

    @isTest
    static void testGetOpportunityContractField() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity result = OpportunityDocumentCtrl.getOpportunityContractField(opp.Id);
        Test.stopTest();

        System.assertEquals(opp.Id, result.Id);
    }

    @isTest
    static void testSendEmailWithAttach() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        // Update Opportunity with Document IDs
        opp.Contract_Document_1Id__c = cv.ContentDocumentId;
        update opp;

        Test.startTest();
        OpportunityDocumentCtrl.sendEmailwithAttach(opp);
        Test.stopTest();

        List<EmailMessage> emails = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
        System.assert(emails.size() > 0, 'Expected at least one EmailMessage');

        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :emails[0].Id];
        System.assert(attachments.size() > 0, 'Expected at least one attachment');
    }
}
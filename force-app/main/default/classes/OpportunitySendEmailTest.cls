@isTest
public class OpportunitySendEmailTest {
	 @testSetup
    public static void testSetup(){
        List<Account> accList = new List<Account>();
        accList.add(
            new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor - Pro Serv').getRecordTypeId(),
                Name = 'Test Account',
                Vendor_Email__c = 'test2@cmentor.com',
                Market__c = 'MEM',
                Status__c = 'Active',
                Type = 'Lender'                
            )
        );
        insert accList;
        
        List<Contact> listCon = new List<Contact>();
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id                
            )
        );
        listCon.add(
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(),
                FirstName = 'Test2',
                LastName='Con',
                Email = 'test@cmentor.com',
                Account = accList[0],
                AccountId = accList[0].Id
            )
        );
        Insert listCon;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(
            new opportunity(
                Name = 'Opp 0',
                AccountId = accList[0].id,
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(),
                CloseDate = date.today(),
                //House__c = houseList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
                //Assessment__c = asmtList[0].id,
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
                Info_Source__c = 'MLS'
            )
        );
        insert oppList;
    }
    
    @isTest 
    public static void testInboundMail(){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<Contact> conList = [SELECT Id FROM Contact];
        oppList[0].Intro_Lender_1__c = conList[0].Id;
        oppList[0].Intro_Lender_1_Intro_Email__c = FALSE;
        //oppList[0].Owner_Account_1_Signer_1__c = conList[0].Id;
        oppList[0].Intro_Lender_2__c = conList[0].Id;
        oppList[0].Intro_Lender_2_Intro_Email__c = FALSE;
        oppList[0].Intro_Lender_1_Account__c = 'test';
        oppList[0].Intro_Lender_2_Account__c = 'test';
        update oppList;
        oppList[0].Intro_Lender_1_Intro_Email__c = TRUE;
        oppList[0].Intro_Lender_2_Intro_Email__c = TRUE;
        update oppList;
        //Lead ld=SalesOppIntroEmailServiceTest.insertLead();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Email Subject';
        email.fromAddress = 'test@testorg.com';
        email.subject='REF: '+oppList[0].Id+'</LeadId>';
        
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        Messaging.InboundEmail.TextAttachment inboundAttachment2 = new Messaging.InboundEmail.TextAttachment();
        // set the body of the attachment
        inboundAttachment.body = blob.valueOf('test');
        inboundAttachment.fileName = 'Email_Attachment.txt';
        inboundAttachment.mimeTypeSubType = 'text/plain';
        
        inboundAttachment2.body = 'test';
        inboundAttachment2.fileName = 'Email_Attachment.txt';
        inboundAttachment2.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { inboundAttachment2 }; 
        OpportunitySendEmail salesEmailSrv = new OpportunitySendEmail(); 
        salesEmailSrv.handleInboundEmail(email, env);   
    }
}
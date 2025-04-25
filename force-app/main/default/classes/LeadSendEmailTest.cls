@isTest
public class LeadSendEmailTest {
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
        
        insert new One_to_One_Lead_Ref__c(Not_One_to_One__c = 0, One_to_One__c = 5); 
        
        Lead ld = new Lead();
            ld.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId();
            ld.FirstName = 'First';
            ld.LastName = 'Last';
            ld.Email = 'test@email.com';
            ld.Phone = '999888777';
            ld.MobilePhone = '987987987';
            ld.Status = 'Open';
            ld.Street = 'Test Street';
            ld.City = 'Test City';
            ld.State = 'MS';
            ld.postalCode = '12345';
            ld.Country = 'Test Country';
            ld.Company = 'Test Company';
            ld.Market__c = 'MEM';
            ld.lead_details__c = 'Test Company';
            ld.Original_Source_Data_3__c = 'Front Desk Email Lead';
            ld.Original_Source_Data_4__c = 'Fortune Builders Client';
            ld.Listing_Date__c = date.today();
            ld.LeadSource = 'MLS';
            ld.One_to_One_Lead__c = TRUE;
            Insert ld;
        
    }
    
    @isTest 
    public static void testInboundMail(){
        List<Lead> oppList = [SELECT Id FROM Lead];
        List<Contact> conList = [SELECT Id FROM Contact];
        
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
        LeadSendEmail leadEmailSrv = new LeadSendEmail(); 
        leadEmailSrv.handleInboundEmail(email, env);   
    }
}
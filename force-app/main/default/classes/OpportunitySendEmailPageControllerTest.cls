@isTest
public class OpportunitySendEmailPageControllerTest {
    
    @TestSetUp
    static void TestData() {
        Account a = new Account();
		a.Name = 'Test Co.';
		a.BillingStreet = '298 S. Ringo Street';
		a.BillingCity = 'Little Rock';
		a.BillingState = 'AR';
		a.BillingPostalCode = '72201';
		a.BillingCountry = 'USA';
		a.Phone = '501-555-5555';
		a.Website = 'www.testco.com';
		insert a;
			
		//Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = a.id;
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Little Rock';
		c.MailingState = 'AR';
		c.MailingPostalCode = '72201'; 
        c.Email = 'Test@abc.com';
		insert c;
			
		//Then create another non-primary contact
		Contact ci = new Contact();
		ci.FirstName = 'Bob';
		ci.LastName  = 'Test';
		ci.AccountId = a.id;
		ci.MailingStreet = '298 S. Ringo Street';
		ci.MailingCity = 'Little Rock';
		ci.MailingState = 'AR';
		ci.MailingPostalCode = '72201'; 
        ci.Email = 'Test@acn.com';
		insert ci;
		System.debug('created primary contact');
			
        House__c hs = new House__c();
        insert hs;
        
        
        
		//Now create an opportunity
		Opportunity o = new Opportunity();
		o.Name = 'New Record';
		o.StageName = 'Posted';
        o.AccountId = a.id;
        o.LeadSource = 'Wholesaler';
        o.Listing_Date__c = date.today();
        o.Follow_Up_Sold_Date__c = date.today();
        o.House__c = hs.id;
        o.CloseDate = date.today();
		insert o;
        
        Attachment attach = new Attachment();
        attach.Name = 'Template 1';
        attach.ParentId = o.Id;
        attach.Body = Blob.valueOf('Body Text');
        insert attach;
			
		//Now update the OCR for the primary contact
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = o.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Decision Maker';
		insert ocr;
			
       
		
    }
    
    
    @isTest
    static void method() {
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        
        //PageReference pageRef = Page.SendEmailProjectItem;
        //Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.lookupName = 'AdditionalTo';
        Ctrl.deleteLookupValueFromList();
        ctrl.lookupName = 'CC';
        Ctrl.deleteLookupValueFromList();
        ctrl.lookupName = 'BCC';
        Ctrl.deleteLookupValueFromList();
        ctrl.lookupName = 'AdditionalTo';
        ctrl.fillMultiLookupsValues();
        ctrl.lookupName = 'CC';
        ctrl.fillMultiLookupsValues();
        ctrl.lookupName = 'BCC';
        ctrl.fillMultiLookupsValues();
        
        ctrl.getFrom();
        
        ctrl.getEmailTemplateFolderOpts();
        ctrl.getEmailTemplateOpts();
        ctrl.getFileLocation();
        //ctrl.selectedDocumentFolder = 'Test';
        //ctrl.getDocumentOpts();
        ctrl.selectedDocumentFolder = 'Notes & Attachments';
        ctrl.getDocumentOpts();
        
    }

    
    @isTest
    static void method_1() {
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Account accObj = [SELECT Id FROM Account LIMIT 1];
        //PageReference pageRef = Page.SendEmailProjectItem;
        //Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.refreshDocumentSection();
        
        ctrl.selectedEmailTemplateFolder  = null;
        ctrl.refreshEmailTemplateSection();
        ctrl.selectedEmailTemplate = null;
        ctrl.refreshEmailTemplateSection();
        ctrl.selectedEmailTemplate = 'test'; 
        ctrl.refreshEmailTemplateSection();
        ctrl.selectedDocumentFolder = 'My Computer';
        ctrl.newfilename = 'Test';
        ctrl.newbody = 'Test';
        ctrl.newFileId = 'Test';
        ctrl.attachFile();
        ctrl.rowIndexAttach = '1';
        
        ctrl.deleteAttachment();
        ctrl.send();
        OpportunitySendEmailPageController.getLookupRecord('Test','Contact');
        OpportunitySendEmailPageController.getLookupRecord('Test','Account');
        OpportunitySendEmailPageController.getLookupRecordUserContact('Test', accObj.id);
        
    }
    
     @isTest
    static void method_3() {
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Account accObj = [SELECT Id FROM Account LIMIT 1];

        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.ccEmails.add('Test@abc.com');
        ctrl.additionalToEmails.add('Test@abc.com');
        ctrl.send();
       
        
    }
    
    
    @isTest
    static void method_4() {
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Account accObj = [SELECT Id FROM Account LIMIT 1];

        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.selectedDocument  = 'Test';
        ctrl.selectedDocumentFolder = 'Test';
        ctrl.attachFile();
       
        
    }

    
    @isTest
    static void method_5() {
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.selectedEmailTemplateFolder  = 'Test';
        ctrl.selectedEmailTemplate = 'trtr';
        ctrl.refreshEmailTemplateSection();
       
        
    }
    
    @isTest
    static void method_6(){
        
        OpportunityContactRole obj = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Account accObj = [SELECT Id FROM Account LIMIT 1];
        
        //PageReference pageRef = Page.SendEmailProjectItem;
        //Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        OpportunitySendEmailPageController Ctrl = new OpportunitySendEmailPageController(sc);
        ctrl.refreshDocumentSection();
        
        ctrl.selectedEmailTemplateFolder  = null;
        ctrl.refreshEmailTemplateSection();
        ctrl.selectedEmailTemplate = null;
        ctrl.refreshEmailTemplateSection();
        ctrl.selectedEmailTemplate = 'test'; 
        ctrl.refreshEmailTemplateSection();
        ctrl.getFrom();
        
        ctrl.getEmailTemplateFolderOpts();
        ctrl.getEmailTemplateOpts();
        ctrl.getFileLocation();
        ctrl.emailTo = 'test@cmentor.com';
        OrgWideEmailAddress[] addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        ctrl.emailFrom = addresses[0].id;
        ctrl.subject = 'Test Subject';
        ctrl.body = 'Test body';
        ctrl.emailToName = 'test';
        ctrl.selectedDocumentFolder = 'Notes & Attachments';
        ctrl.selectedDocument = 'Selected Document';
        ctrl.newfilename = 'Test';
        ctrl.newbody = 'Test';
        ctrl.newFileId = 'Test';
        ctrl.attachFile();
        ctrl.rowIndexAttach = '2';
        
        ctrl.deleteAttachment();
        ctrl.send();
        OpportunitySendEmailPageController.getLookupRecord('Test','Contact');
        OpportunitySendEmailPageController.getLookupRecord('Test','Account');
        OpportunitySendEmailPageController.getLookupRecordUserContact('Test', accObj.id);
        
    }

}
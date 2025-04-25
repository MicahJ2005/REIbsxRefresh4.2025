@isTest
/**
    Name        : SendEmailControllerTest
    Date        : May 02, 2019
    Author      : Shweta Fulara (Cmentor)
    Description : This class is used for code coverage of SendEmailController
**/
private class SendEmailControllerTest {
	@testSetup 
    static void setup() {
        
        Account accVendor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(), '');
        insert accVendor;
        
        Contact conVendor = TestDataFactory.createContact('Vendor', 'Tester', '9879654321', 'testaccVendorsf@tester.com', accVendor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId()
        );
        insert conVendor;
        
        Account accInvestor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(), '');
        //accInvestor.Customer_Service_Assignment__c = UserInfo.getUserId();
        insert accInvestor;
        
        Contact conInvestor = TestDataFactory.createContact('Investor', 'Tester', '9879654321', 'testInvestorsf@tester.com', accInvestor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        conInvestor.Phone = '1234567890';
        conInvestor.MobilePhone = '123456789';
        conInvestor.Email = 'test@abc.com';
        conInvestor.Birthdate = date.today();
        conInvestor.MailingStreet = 'test street';
        conInvestor.MailingCity = 'NY';
        conInvestor.MailingState = 'Alabama';
        conInvestor.MailingPostalCode  = '12345';
        insert conInvestor;
        
        House__c house = TestDataFactory.createHouse('Test Property', 'Test Property', 'Test Streeet', 'Memphis', 'TN', '39876', 'US');
        house.Investor__c = accInvestor.Id;
        insert house;
        
        Account acc = TestDataFactory.createAccount('Owner acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resident').getRecordTypeId(), '');
        insert acc;
        
        Contact con = TestDataFactory.createContact('Test', 'Tester', '9879654321', 'testsf@tester.com', acc.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resident').getRecordTypeId()
        );
        insert con;
        
        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId(), 'Open', 
            con.Id, house.Id, 'Test desc.', '9998887878', System.now(), false, System.now().addMonths(1), categoryEntries[0].getValue()
        );
        insert cs;
        
        Id maintenanceProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
                
        Project__c project = new Project__c(House__c=house.Id,
                                                    Description__c='Test desc.', Account__c= acc.Id,
                                                    Case__c=cs.Id, RecordTypeId=maintenanceProjectRecTypeId);
        insert project;
        
        Project_Item__c projectItem = new Project_Item__c(Project__c=project.Id, Case__c=cs.Id, Description__c='Test desc.', Maintenance_Status__c ='Active Dispatched',
                                                         MaintenanceCategoryGlobal__c = 'Flooring',
                                                          MaintenanceSubCategoryGlobal__c = 'Water Extraction',
                                                         Name='WO-MEM-00001303-01');
        insert projectItem;
        
        Project_Item_Bid__c bid = new Project_Item_Bid__c(Project_Item__c=projectItem.Id, SOW_Description__c='sow test', Owner_Accepted__c=true);
        insert bid;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser )
        {
            UserRole r = new UserRole(DeveloperName = 'Customer_Service', Name = 'Customer Service');
            insert r;
    
            String orgId = userInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = 'Test',
                                    lastName = 'LastNm',
                                    email = uniqueName + '@test' + orgId + '.org',
                                    Username = uniqueName + '@test' + orgId + '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                                    UserRoleId = r.Id);
            insert tuser;
        }
    }
    
    @isTest
    static void testMethod1(){
        
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        
        PageReference pageRef = Page.SendEmail;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('relatedId', projectItem.Id);
        
        SendEmailController sendEmailCtrl = new SendEmailController();
        SendEmailController.getLookupRecord('Investor', 'Contact');
        
        sendEmailCtrl.getFrom();
        sendEmailCtrl.getEmailTemplateFolderOpts();
        sendEmailCtrl.getEmailTemplateOpts();
        sendEmailCtrl.getFileLocation();
        sendEmailCtrl.getDocumentOpts();
        sendEmailCtrl.refreshDocumentSection();
        sendEmailCtrl.refreshEmailTemplateSection();        
        sendEmailCtrl.attachFile();
        sendEmailCtrl.deleteAttachment();
        sendEmailCtrl.lookupName = 'CC';
        sendEmailCtrl.rowIndex = '0';
        sendEmailCtrl.deleteLookupValueFromList();
		
        sendEmailCtrl.lookupEmail = 'testInvestorsf@tester.com';
		sendEmailCtrl.fillMultiLookupsValues();        
    }
    
    @isTest
    static void testMethod2(){
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        
        List<Folder> lstFolder1 = [Select Id From Folder Where Name = 'Public'];

        Document document = new Document(FolderId = lstFolder1[0].Id, Name='Test Name',Keywords = 'Test');
        insert document;
        
        Attachment attach = new Attachment();   	
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = projectItem.id;
        insert attach;
        
        ContentVersion cv = new Contentversion(); 
        cv.Title = 'TestCV'; 
        cv.PathOnClient = 'TestCV'; 
        cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cv;
            
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = projectItem.id;
        contentlink.contentdocumentid = contentVersion.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        PageReference pageRef = Page.SendEmail;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('relatedId', projectItem.Id);
        
        SendEmailController sendEmailCtrl = new SendEmailController();
        SendEmailController.getLookupRecord('Investor', 'Contact');
        
        sendEmailCtrl.getFileLocation();
        sendEmailCtrl.selectedDocumentFolder = lstFolder1[0].Id;
        sendEmailCtrl.getDocumentOpts();
        //Notes & Attachment with doc
        sendEmailCtrl.selectedDocumentFolder = 'Notes & Attachments';
        sendEmailCtrl.getDocumentOpts();
        sendEmailCtrl.selectedDocument = document.Id;
        sendEmailCtrl.attachFile();
        //Notes & Attachment with CV
        sendEmailCtrl.selectedDocument = cv.Id;
        sendEmailCtrl.attachFile();
        //My Computer
        sendEmailCtrl.selectedDocumentFolder = 'My Computer';
        sendEmailCtrl.newfilename = 'FileMyPC';
        sendEmailCtrl.newbody = 'Testing';
        sendEmailCtrl.attachFile();
        sendEmailCtrl.newbody = '';
        sendEmailCtrl.newFileId = document.Id;
        sendEmailCtrl.attachFile();
        sendEmailCtrl.selectedDocumentFolder = 'Public';
        sendEmailCtrl.selectedDocument = document.Id;
        sendEmailCtrl.attachFile();
        
        sendEmailCtrl.rowIndexAttach = '0';
        sendEmailCtrl.deleteAttachment();
        sendEmailCtrl.send();
        
        SendEmailController.getLookupRecordUserContact('Investor', '');
        SendEmailController.getLookupRecordUserContact('LastNm', '');
        SendEmailController.getLookupRecordUserContact('', '');
        SendEmailController.getLookupRecord('Investor', 'Account');
    }
    
    @isTest
    static void testMethod3(){
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        
        List<Folder> lstFolder = [Select Id From Folder Where DeveloperName = 'Maintenance'];
        EmailTemplate et = new EmailTemplate (developerName = 'test_Miaintenance', FolderId = lstFolder[0].Id, TemplateType= 'custom', Name = 'test_Miaintenance', IsActive = true); // plus any other fields that you want to set
        insert et;
        
        EmailTemplate et1 = new EmailTemplate (developerName = 'test_Miaintenance1', FolderId = lstFolder[0].Id, TemplateType= 'custom', Name = 'test_Miaintenance1'); // plus any other fields that you want to set
        insert et1;
        
        PageReference pageRef = Page.SendEmail;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('relatedId', projectItem.Id);
        
        SendEmailController sendEmailCtrl = new SendEmailController();
        SendEmailController.getLookupRecord('Investor', 'Contact');
        
        sendEmailCtrl.getEmailTemplateFolderOpts();
        sendEmailCtrl.selectedEmailTemplateFolder = lstFolder[0].Id;
        sendEmailCtrl.getEmailTemplateOpts();   
        sendEmailCtrl.emailTo = String.valueOf(thisUser.Id);
        OrgWideEmailAddress[] addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        sendEmailCtrl.emailFrom = String.valueOf(addresses[0].Id);
        sendEmailCtrl.selectedEmailTemplate = et.Id;
        sendEmailCtrl.refreshEmailTemplateSection();
        sendEmailCtrl.selectedEmailTemplate = et1.Id;
        sendEmailCtrl.refreshEmailTemplateSection();
        if(!addresses.isEmpty()){
        	sendEmailCtrl.emailFrom = String.valueOf(addresses[0].Id);
        }
        sendEmailCtrl.send();
    }
    
    @isTest
    static void testMethod4(){
        
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        
        PageReference pageRef = Page.SendEmail;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('relatedId', projectItem.Id);
        
        SendEmailController sendEmailCtrl = new SendEmailController();
        SendEmailController.getLookupRecord('Investor', 'Contact');
        
        sendEmailCtrl.getFrom();
        sendEmailCtrl.getEmailTemplateFolderOpts();
        sendEmailCtrl.getEmailTemplateOpts();
        sendEmailCtrl.getFileLocation();
        sendEmailCtrl.getDocumentOpts();
        sendEmailCtrl.refreshDocumentSection();
        sendEmailCtrl.refreshEmailTemplateSection();        
        sendEmailCtrl.attachFile();
        sendEmailCtrl.deleteAttachment();
        sendEmailCtrl.lookupName = 'AdditionalTo';
        sendEmailCtrl.rowIndex = '0';
        sendEmailCtrl.deleteLookupValueFromList();
        sendEmailCtrl.lookupEmail = 'testInvestorsf@tester.com';
		sendEmailCtrl.fillMultiLookupsValues(); 
        
        sendEmailCtrl.lookupName = 'BCC';
        sendEmailCtrl.deleteLookupValueFromList();
        sendEmailCtrl.lookupEmail = 'testInvestorsf@tester.com';
		sendEmailCtrl.fillMultiLookupsValues();        
    }
}
@isTest
/**
    Name        : EmailActionTest
    Date        : April 12, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : This test class is used for code coverage of EmailAction.
**/
private class EmailActionTest {
    @testSetup 
    static void setup() {
        Account accVendor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId(), '');
        insert accVendor;
        
        Contact conVendor = TestDataFactory.createContact('Vendor', 'Tester', '9879654321', 'testaccVendorsf@tester.com', accVendor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId()
        );
        insert conVendor;
        
        Account accInvestor = TestDataFactory.createAccount('Investor acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(), '');
        insert accInvestor;
        
        Contact conInvestor = TestDataFactory.createContact('Investor', 'Tester', '9879654321', 'testInvestorsf@tester.com', accInvestor.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        insert conInvestor;
        
        House__c house = TestDataFactory.createHouse('Test Property', 'Test Property', 'Test Streeet', 'Memphis', 'TN', '39876', 'US');
        house.Investor__c = accInvestor.Id;
        insert house;
        
        Account acc = TestDataFactory.createAccount('Owner acc', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(), '');
        insert acc;
        
        Contact con = TestDataFactory.createContact('Test', 'Tester', '9879654321', 'testsf@tester.com', acc.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        con.HasOptedOutOfEmail = true;
        insert con;
        
        Contact con1 = TestDataFactory.createContact('Test', 'Tester1', '8879654321', 'testsf1@tester.com', acc.Id, 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Investor').getRecordTypeId()
        );
        insert con1;
        
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
        
        Project_Item__c projectItem = new Project_Item__c(Project__c=project.Id, Case__c=cs.Id, Description__c='Test desc.', Status__c='Active',
                                                         MaintenanceCategoryGlobal__c = 'Flooring',
                                                          MaintenanceSubCategoryGlobal__c = 'Water Extraction',
                                                         Name='WO-MEM-00001303-01');
    	insert projectItem;
        
        Project_Item_Bid__c bid = new Project_Item_Bid__c(Project_Item__c=projectItem.Id, SOW_Description__c='sow test', Owner_Accepted__c=true);
        insert bid;
    }
    
	static testmethod void test1(){
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Maintenance_Follow_Up_Activity_Confirmation_of_Satisfaction'];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name ='Test Tester'];
        
        EmailAction.EmailActionRequest request = new EmailAction.EmailActionRequest();
        request.subject = 'Maintenance Follow-Up 1';
        request.ccAddress = 'test@sf1.com';
        request.bccAddress = 'test@sf2.com';
        request.htmlBody = 'Testing';
        request.plainTextBody = 'Testing';
        request.emailTemplateId = emailTemplate.Id;
        //request.orgWideEmailAddressId = 'orgwide@sf.com';
        request.displayName = 'MI';
        request.targetObjectId = con.Id;
        request.whatId = projectItem.Id;
        request.saveAsActivity = true;
        
        EmailAction.sendEmails(new List<EmailAction.EmailActionRequest>{request});
    }
    
    static testmethod void test2(){
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Maintenance_Follow_Up_Activity_Confirmation_of_Satisfaction'];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name ='Test Tester1'];
        
        EmailAction.EmailActionRequest request = new EmailAction.EmailActionRequest();
        request.subject = 'Maintenance Follow-Up 1';
        request.ccAddress = 'test@sf1.com';
        request.bccAddress = 'test@sf2.com';
        request.htmlBody = 'Testing';
        request.plainTextBody = 'Testing';
        request.emailTemplateId = emailTemplate.Id;
        //request.orgWideEmailAddressId = 'orgwide@sf.com';
        request.displayName = 'MI';
        request.targetObjectId = con.Id;
        request.whatId = projectItem.Id;
        request.saveAsActivity = true;
        
        EmailAction.sendEmails(new List<EmailAction.EmailActionRequest>{request});
    }
    
    static testmethod void test3(){
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Maintenance_Follow_Up_Activity_Confirmation_of_Satisfaction'];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        
        EmailAction.EmailActionRequest request = new EmailAction.EmailActionRequest();
        request.subject = 'Maintenance Follow-Up 1';
        request.ccAddress = 'test@sf1.com';
        request.bccAddress = 'test@sf2.com';
        request.htmlBody = 'Testing';
        request.plainTextBody = 'Testing';
        request.emailTemplateId = emailTemplate.Id;
        request.displayName = 'MI';
        request.targetObjectId = UserInfo.getUserId();
        request.whatId = projectItem.Id;
        request.saveAsActivity = false;
        
        EmailAction.sendEmails(new List<EmailAction.EmailActionRequest>{request});
    }
}
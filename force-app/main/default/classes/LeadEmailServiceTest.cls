@isTest
public class LeadEmailServiceTest {
    
     @testSetup
    public static void TestData(){
        Insert new One_to_One_Lead_Ref__c(Not_One_to_One__c = 0, One_to_One__c = 5); 
    }
    
    static testmethod void test1(){
        
        List<Lead> objLst = new List<Lead>();
        Lead ld = TestDataFactory.createLead('Test First Name','Test Last Name','Test@gmail.com','123456789','12345');
        ld.recordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get(label.Buyer_RecordType_On_Lead).getRecordTypeId();
        ld.Street = 'Test Street';
        ld.City = 'Test City';
        ld.State = 'MS';
        ld.postalCode = '12345';
        ld.Country = 'Test Country';
        ld.Company = 'Test Company';
        ld.Market__c = 'MEM';
        ld.lead_details__c = 'Test Company';
        objLst.add(ld);
        insert objLst;
        
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
        
        Project_Item__c projectItem = new Project_Item__c(Project__c=project.Id, Case__c=cs.Id, Description__c='Test desc.', Status__c='Active',
                                                          MaintenanceCategoryGlobal__c = 'Flooring',
                                                          MaintenanceSubCategoryGlobal__c = 'Water Extraction',
                                                          Name='WO-MEM-00001303-01');
        insert projectItem;
        
        Project_Item_Bid__c bid = new Project_Item_Bid__c(Project_Item__c=projectItem.Id, SOW_Description__c='sow test', Owner_Accepted__c=true);
        insert bid;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'Over $400 Post-work Notification (QOL) - Test Streeet';
        email.htmlbody = 'Testing';
        email.htmlbody += '\n';
        email.htmlbody += '  ';
        email.plainTextBody += '\n';
        email.htmlbody += ' [ref: '+ projectItem.Id + '] [userRef: '+ UserInfo.getUserId() + ']';
        
        email.fromAddress = 'test@gmail.com';
        email.toAddresses = new List<String>{'testkkk@gmail.com'};
            email.ccAddresses = new List<String>{'testkkk1@gmail.com','testkkk2@gmail.com'};
                
                Test.startTest();
        LeadEmailService emailHandler = new LeadEmailService();
        
        Messaging.InboundEmailResult result = emailHandler.handleInboundEmail(email, envelope);
        email.htmlbody = null;
        result = emailHandler.handleInboundEmail(email, envelope);
        //System.assertEquals( result.success  ,true);
        Test.stopTest();
        
    }
    
}
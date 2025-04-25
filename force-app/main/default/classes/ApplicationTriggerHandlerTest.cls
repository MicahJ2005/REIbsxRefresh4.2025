@isTest
public class ApplicationTriggerHandlerTest {
    @testSetup
    public static void testSetup(){
        Trigger_Switch__c setting = new Trigger_Switch__c();
        setting.Name = 'Opportunity';
        setting.Is_Enabled__c =  true;
        insert setting;
        
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
                AccountId = accList[0].Id,
                Is_Primary__c = TRUE                
            )
        );
        insert listCon;
        List<Assessment__c> asmtList = new List<Assessment__c>();
        asmtList.add(
            new Assessment__c(
                Name = 'Asmt-0',
                Market__c = 'MEM',
                Bedrooms__c = '2',
                Bathrooms__c = '2',
                Car_Storage_Parking__c = '2GD',
                Year_Built__c = '1962',
                Square_Ft__c = 100,
                Status__c = 'Completed'
            )
        );
        insert asmtList;
        List<House__c> houseList = new List<House__c>();
        houseList.add(
            new House__c(
                Name = 'Test House',
                City__c = 'Test City',
                State__c = 'MS',
                Zip_Code__c = '12345',
                Street_Address__c = 'Test Street Address'
            )
        );
        insert houseList;
        
        List<opportunity> oppList = new List<Opportunity>();

        oppList.add(
            new opportunity(
                Name = 'Opp 0',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId(),
                Lender_Name__c = listCon[0].Id,
                Lender_Approval__c = 'Y',
                CloseDate = date.today(),
                House__c = houseList[0].id,
                Assessment__c = asmtList[0].id,
                StageName = 'RecordTypeId = RecordTypeId',
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
                Info_Source__c = 'MLS',
                LeadSource = 'WEB'
            )
        );
        insert oppList;
        
        Id renovationRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        List<Project__c> projectList = new List<Project__c>();
        projectList.add(
            new Project__c(
                RecordTypeId = renovationRecordTypeId,
                Opportunity__c = oppList[0].id,
                House__c = houseList[0].id,
                Pay_Account__c = 'New MEM'
            )
        );
        projectList.add(
            new Project__c(
                RecordTypeId = renovationRecordTypeId,
                House__c = houseList[0].id,
                Pay_Account__c = 'New MEM'
            )
        );
        projectList.add(
            new Project__c(
                RecordTypeId = renovationRecordTypeId,
                House__c = houseList[0].id,
                Pay_Account__c = 'New MEM'
            )
        );
        insert projectList;
        
        List<Application__c> applicationList = new List<Application__c>();
        applicationList.add(
            new Application__c(
                Address__c = 'Test Address',
                Project__c = projectList[0].Id,
                Status__c = 'Working/Need Info',
                Market__c = 'MEM',
                Applicant_1__c = 'Test',
                Phone_Number__c = '9899',
                Email__c = 'test@cmentor.com',
                Date_Received__c = System.today()
            )
        );
        applicationList.add(
            new Application__c(
                Address__c = 'Test Address 2',
                Project__c = projectList[1].Id,
                Status__c = 'Working/Need Info',
                Market__c = 'MEM',
                Applicant_1__c = 'Test',
                Phone_Number__c = '9899',
                Email__c = 'test@cmentor.com',
                Date_Received__c = System.today()
            )
        );
        insert applicationList;
    }
    
    @isTest
    public static void beforeInsert(){
        List<Application__c> applicationList = [SELECT Id, Project__c FROM Application__c];
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        try{
            Application__c app = new Application__c();
            app.Address__c = 'Test Address';
            app.Project__c = projectList[0].Id;
            app.Status__c = 'Working/Need Info';
            app.Market__c = 'MEM';
            app.Applicant_1__c = 'Test';
            app.Phone_Number__c = '9899';
            app.Email__c = 'test@cmentor.com';
            insert app; 
        }catch(Exception ex){
            
        }
        
    }
    
    @isTest
    public static void beforeUpdate(){
        List<Application__c> applicationList = [SELECT Id, Project__c FROM Application__c];
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        try{
            applicationList[0].Project__c = projectList[0].Id;
            update applicationList[0];
            applicationList[1].Project__c = projectList[0].Id;
            update applicationList[1];
        }catch(Exception ex){
            
        }
    }
}
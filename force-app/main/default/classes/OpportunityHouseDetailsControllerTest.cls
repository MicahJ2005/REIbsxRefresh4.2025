@isTest
public class OpportunityHouseDetailsControllerTest {
    
    @isTest static void mymethod(){
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        House__c H1 = New House__c();
        H1.Name = 'house';
        H1.Market__c = 'MEM';
        H1.Appraised_Amount__c =10;
        H1.Appraised_Date__c = system.today();
        H1.Lease_Closing_Date__c = system.today()+1;
        H1.Rent_Year_1__c = 10;
        H1.Sale_Amount__c = 10;
        H1.Sales_Date__c = system.today();
        H1.Source__c = 'Internal';
        insert H1;
        
        House__c H2 = New House__c();
        H2.Name = 'house';
        H2.Market__c = 'MEM';
        H2.Appraised_Amount__c =10;
        H2.Appraised_Date__c = system.today();
        H2.Lease_Closing_Date__c = system.today()+1;
        H2.Rent_Year_1__c = 10;
        H2.Sale_Amount__c = 10;
        H2.Sales_Date__c = system.today();
        H2.Source__c = 'Internal';
        insert H2;
        
        
        House__c H3 = New House__c();
        H3.Name = 'house';
        H3.Market__c = 'MEM';
        H3.Appraised_Amount__c =10;
        H3.Appraised_Date__c = system.today();
        H3.Lease_Closing_Date__c = system.today()+1;
        H3.Rent_Year_1__c = 10;
        H3.Sale_Amount__c = 10;
        H3.Sales_Date__c = system.today();
        H3.Source__c = 'Internal';
        insert H3;
        
        Project__c proObj = new Project__c();
        proObj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        proObj.House__c = H1.Id;
        insert proObj;
        
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList.add(
            new Opportunity(
                
                Name = 'Opp 0',
                AccountId = acc.id,
                Listing_Date__c = system.today(),
                Follow_Up_Sold_Date__c = system.today(),
                House__c = H1.id,
                Project_Evaluation_1__c = proObj.id,
                Project_Evaluation_1_Status__c = 'Selected',
                StageName = 'RecordTypeId = RecordTypeId',
                LeadSource = 'Facebook',
                CloseDate = date.today()
            ));
        Insert oppList; 
        OpportunityHouseDetailsController.getHouse(oppList[0].id);
        
    }
    @isTest static void mymethod1(){
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
       
       
        
        House__c H3 = New House__c();
        H3.Name = 'house';
        H3.Market__c = 'MEM';
        H3.Appraised_Amount__c =10;
        H3.Appraised_Date__c = system.today();
        H3.Lease_Closing_Date__c = system.today()+1;
        H3.Rent_Year_1__c = 10;
        H3.Sale_Amount__c = 10;
        H3.Sales_Date__c = system.today();
        H3.Source__c = 'Internal';
        insert H3;
        
        Project__c proObj = new Project__c();
        proObj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        proObj.House__c = H3.Id;
        insert proObj;
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList.add(
            new Opportunity(
                
                Name = 'Opp 0',
                AccountId = acc.id,
                Listing_Date__c = system.today(),
                Follow_Up_Sold_Date__c = system.today(),
                House__c = H3.id,
                Project_Evaluation_3__c = proObj.id,
                Project_Evaluation_3_Status__c = 'Selected',
                StageName = 'RecordTypeId = RecordTypeId',
                LeadSource = 'Facebook',
                CloseDate = date.today()
            ));
        Insert oppList; 
        OpportunityHouseDetailsController.getHouse(oppList[0].id);
    }
    @isTest static void mymethod2(){
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
       
        
        House__c H2 = New House__c();
        H2.Name = 'house';
        H2.Market__c = 'MEM';
        H2.Appraised_Amount__c =10;
        H2.Appraised_Date__c = system.today();
        H2.Lease_Closing_Date__c = system.today()+1;
        H2.Rent_Year_1__c = 10;
        H2.Sale_Amount__c = 10;
        H2.Sales_Date__c = system.today();
        H2.Source__c = 'Internal';
        insert H2;
        
        
        Project__c proObj = new Project__c();
        proObj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        proObj.House__c = H2.Id;
        insert proObj;
        
        
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList.add(
            new Opportunity(
                
                Name = 'Opp 0',
                AccountId = acc.id,
                Listing_Date__c = system.today(),
                Follow_Up_Sold_Date__c = system.today(),
                House__c = H2.id,
                 Project_Evaluation_2__c = proObj.id,
                Project_Evaluation_2_Status__c = 'Selected',
                StageName = 'RecordTypeId = RecordTypeId',
                LeadSource = 'Facebook',
                CloseDate = date.today()
            ));
        Insert oppList; 
        OpportunityHouseDetailsController.getHouse(oppList[0].id);
    }
}
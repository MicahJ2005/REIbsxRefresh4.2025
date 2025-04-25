@isTest
public class UpdateProjDaysAvailableBatchTest {
   
    @isTest static void UnitTest(){
        
        Account acc = new Account(Name ='Test acc');
        insert acc;
        
        House__c house = new House__c();
        house.Name = 'Test Name';
        house.State__c = 'MS';
        house.Street_Address__c = '703 Stell Ave';
        house.Street_Address_Line_2__c = '703 Stell Ave';
        house.City__c = 'Mansfield';
        house.State__c = 'TX';
        house.Zip_Code__c = '76063-2017';
        house.Lease_Terms__c  = '6 months';
        insert house; 
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investor Prospect').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        // 0
        oppList.add(
            new Opportunity(
                RecordTypeId = RecordTypeIdOpp,
                Name = 'Opp 0',
                StageName = 'Pre-Assessment',
                Closing_Stage__c = 'Start',
                Make_Available__c = system.today()-10,
                AccountId = acc.id,
                LeadSource = 'Facebook',
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                House__c = house.id,
                CloseDate = date.today()
            )
        );
        Insert oppList;
        
        Id RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        Project__c pro = new Project__c();
        pro.RecordTypeId = RecordTypeId;
        pro.Name = 'test project';
        pro.House__c = house.id;
        pro.Account__c = acc.id;
        pro.Sales_Status__c = 'Available Now/PE Released';
        pro.Project_Status__c = 'Ready to Show';
        pro.Application_Status__c = 'Cancelled';
        pro.Move_Up_Date_New__c = date.today().addDays(-10);
        pro.Make_Available__c = date.today();
        pro.Opportunity__c = oppList[0].id;
        insert pro;
        
        Test.startTest();
        
        UpdateProjDaysAvailableBatch obj = new UpdateProjDaysAvailableBatch();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
      /*
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        House__c house = new House__c();
        house.Name = 'Test Name';
        house.State__c = 'MS';
        house.Street_Address__c = '703 Stell Ave';
        house.Street_Address_Line_2__c = '703 Stell Ave';
        house.City__c = 'Mansfield';
        house.State__c = 'TX';
        house.Zip_Code__c = '76063-2017';
        house.Lease_Terms__c  = '6 months';
        insert house; 
        
        
        Id RecordTypeIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        // Opportunity List
        List<Opportunity> oppList = new List<Opportunity>();
        // 0
        oppList.add(
            new Opportunity(
                RecordTypeId = RecordTypeIdOpp,
                Name = 'Opp 0',
                StageName = 'Pre-Assessment',
                Closing_Stage__c = 'Start',
                Make_Available__c = system.today()-10,
                Days_Available1__c = NULL,
                AccountId = acc.id,
                LeadSource = 'Facebook',
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                House__c = house.id,
                CloseDate = date.today()
            )
        );
        Insert oppList;
        UpdateProjDaysAvailableBatch obj = new UpdateProjDaysAvailableBatch();
        database.executeBatch(obj);
        
    }*/
    
    
}
@isTest
public class OpportunityBuyHouseDetailsCtrlTest {
    
    @isTest static void myMethod(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        House__c H1 = New House__c();
        H1.Name = 'house';
        H1.Market__c = 'MEM';
        // H1.Appraised_SqFt__c = 10;
        H1.Appraised_Amount__c =10;
        H1.Appraised_Date__c = system.today();
        H1.Lease_Closing_Date__c = system.today()+1;
        //sH1.Rent_SqFt__c = 10;
        H1.Rent_Year_1__c = 10;
        H1.Sale_Amount__c = 10;
        // H1.Sale_Amount_SqFt__c = 10;
        H1.Sales_Date__c = system.today();
        H1.Source__c = 'Internal';
        insert H1;
        
        House__c H2 = New House__c();
        H2.Name = 'house';
        H2.Market__c = 'MEM';
        // H1.Appraised_SqFt__c = 10;
        H2.Appraised_Amount__c =10;
        H2.Appraised_Date__c = system.today();
        H2.Lease_Closing_Date__c = system.today()+1;
        //sH1.Rent_SqFt__c = 10;
        H2.Rent_Year_1__c = 10;
        H2.Sale_Amount__c = 10;
        // H1.Sale_Amount_SqFt__c = 10;
        H2.Sales_Date__c = system.today();
        H2.Source__c = 'Internal';
        insert H2;
        
        
        House__c H3 = New House__c();
        H3.Name = 'house';
        H3.Market__c = 'MEM';
        // H1.Appraised_SqFt__c = 10;
        H3.Appraised_Amount__c =10;
        H3.Appraised_Date__c = system.today();
        H3.Lease_Closing_Date__c = system.today()+1;
        //sH1.Rent_SqFt__c = 10;
        H3.Rent_Year_1__c = 10;
        H3.Sale_Amount__c = 10;
        // H1.Sale_Amount_SqFt__c = 10;
        H3.Sales_Date__c = system.today();
        H3.Source__c = 'Internal';
        insert H3;
        
        
        
        List<Opportunity> oppList = new List<Opportunity>();
       
        oppList.add(
            new Opportunity(
                
                Name = 'Opp 0',
                AccountId = acc.id,
                Listing_Date__c = system.today(),
                Follow_Up_Sold_Date__c = system.today(),
                House__c = H1.id,
                Sale_Comp_1__c = H1.id,
                Sale_Comp_2__c = H2.id,
                Sale_Comp_3__c = H3.id,
                Rent_Comp_1__c = H1.id,
                Rent_Comp_2__c = H2.id,
                Rent_Comp_3__c = H3.id,
                StageName = 'RecordTypeId = RecordTypeId',
                LeadSource = 'Facebook',
                CloseDate = date.today()
                // Assessment__c = asmtList[0].id,
            ));
        Insert oppList;
        
        OpportunityBuyHouseDetailsCtrl.getHouse(oppList[0].id);
        
    }
    
}
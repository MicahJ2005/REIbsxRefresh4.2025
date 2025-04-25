@isTest
private class AccountRelatedOpportunitiesCtrlTest {
    
    @testSetup
    public static void testData(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        House__c hs =  new House__c();
        hs.Name = 'Test';
        insert hs;
        
        Assessment__c ass = new Assessment__c();
        ass.Name = 'Test Assessment';
        Insert ass;
        
        List<Opportunity> oppList = new List<Opportunity>();
        // 0
        oppList.add(
            new Opportunity(
                Name = 'Opp-0',
                StageName = 'Pre-Assessment',
                LeadSource = 'MLS',
                AccountId = acc.id,
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                House__c = hs.id,
                Initial_List_Price__c = 100,
                Initial_Offer__c = 99,
                Current_List_Price__c = 120,
             //   Current_Offer__c = 220,
                Assessment__c = ass.id,
                CloseDate = date.today()
            )
        );
        
        // 1
        oppList.add(
            new Opportunity(
                Name = 'Opp-1',
                StageName = 'Pre-Assessment',
                LeadSource = 'MLS',
                AccountId = acc.id,
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                House__c = hs.id,
                Initial_List_Price__c = 100,
                Initial_Offer__c = 99,
                Current_List_Price__c = 120,
             //   Current_Offer__c = 220,
                Assessment__c = ass.id,
                CloseDate = date.today()
            )
        );
        
        // 2
        oppList.add(
            new Opportunity(
                Name = 'Opp-2',
                StageName = 'Pre-Assessment',
                LeadSource = 'MLS',
                AccountId = acc.id,
                Listing_Date__c = date.today(),
                Follow_Up_Sold_Date__c = date.today(),
                House__c = hs.id,
                Initial_List_Price__c = 100,
                Initial_Offer__c = 99,
                Current_List_Price__c = 120,
              //  Current_Offer__c = 220,
                Assessment__c = ass.id,
                CloseDate = date.today()
            )
        );
        Insert oppList;
        AccountRelatedOpportunitiesCtrl.getAccountRelatedOpporunities(oppList[0].id);
        AccountRelatedOpportunitiesCtrl.returnInvestorAccountRelatedOpportunities(oppList[0].id);
    }
    
    @isTest
    public static void defaultTest(){
        
    }

}
@isTest
public class ProjectInvokableClassTest {
    
    @TestSetUp
    static void TestData() {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        Assessment__c ass = new Assessment__c ();
        insert ass;
        
        House__c hs = new House__c();
        insert hs;
        
        
        opportunity opp = new opportunity();
        opp.AccountId = acc.id;
        opp.StageName = 'Pending';
        opp.CloseDate = Date.today();
        opp.Closing_Date__c = date.today();
        opp.Name = 'Test Opportunity Triggers';
        opp.assessment__c = ass.id;
        opp.LeadSource = 'MLS';
        opp.Listing_Date__c = date.today();
        opp.Follow_Up_Sold_Date__c = date.today();
        opp.House__c = hs.id;
        insert opp;
        
        Project__c pro = new Project__c();
        pro.Buy_Opportunity__c = opp.id;
        pro.House__c = hs.id;
        Insert pro;
        
    }
    
    @isTest
    static void method_1(){
        Test.startTest();
        List<id> projIdList = new List<id>();
        List<Project__c> projList = [SELECT Id,Buy_Opportunity__c FROM Project__c];
        for(Project__c proj : projList){
            projIdList.add(proj.id);
        }
        ProjectInvokableClass.setProjectId(projIdList);
        Test.stopTest();
    }
    
    
    
}
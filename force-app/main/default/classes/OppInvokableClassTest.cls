/**
 * @description       : 
 * @author            : Michael Lloyd (Demand Chain)
 * @group             : 
 * @last modified on  : 01-27-2022
 * @last modified by  : Michael Lloyd (Demand Chain)
**/
@isTest
public class OppInvokableClassTest {
    
    @TestSetUp
    static void TestData() {
        /*
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        For(Integer i=1 ;i<=200 ; i++)
        {
            Assessment__c ass = new Assessment__c ();
            assessmentList.add(ass);	   
        }
        insert assessmentList;
        
        House__c hs = new House__c();
        insert hs;
        
        List<opportunity> lstOpp = new List<opportunity> ();
        For(Assessment__c ass : assessmentList){
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
            lstOpp.add(opp);	   
        }
        insert lstOpp;
*/
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        Assessment__c ass = new Assessment__c ();
        insert ass;
        
        House__c hs = new House__c();
        insert hs;
        
        Trigger_Switch__c ts = new Trigger_Switch__c(Name = 'Opportunity', Is_Enabled__c = true);
        insert ts;
        
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
    }
    
    @isTest
    static void method_1(){
        Test.startTest();
        List<id> assIdList = new List<id>();
        List<opportunity> oppList = [SELECT Id,assessment__c FROM opportunity];
        for(opportunity opp : oppList){
            assIdList.add(opp.assessment__c);
        }
        OppInvokableClass.updateRecords(assIdList);
        Test.stopTest();
    }
    
}
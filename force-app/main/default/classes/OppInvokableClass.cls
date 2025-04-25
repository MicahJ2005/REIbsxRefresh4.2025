public class OppInvokableClass {

    @InvocableMethod
    public static void updateRecords(List<Id> assessIds){
        updateRecord(assessIds);
    }
    
    //@future
    public static void updateRecord(List<Id> assessIds){
        List<Opportunity> oppList =[Select id,Rehab_Budget_OS_Can_be_updated__c from Opportunity where assessment__c IN: assessIds ];
        for(Opportunity opp : oppList){
            opp.Rehab_Budget_OS_Can_be_updated__c = false;
        }
        Update oppList;
    }

}
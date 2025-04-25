/*
 * Class : ProjectBacthClass
 * Description : To calculate days vacant  
 * Code By : Cmentor B.A
 * Date : 13-July-2020
 * 
 * */
global class ProjectDaysVacantBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT ID,Days_Vacant1__c,Move_Up_Date_New__c FROM Project__c WHERE Project_Status__c =\'Ready to Show\' AND Application_Status__c != \'Approved with Deposit/Waiting to Close\' AND (RecordType.Name=\'Renovation\' OR RecordType.Name=\'Move Out\')'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<Project__c> projectList) {
        
        for(Project__c pro : projectList){
            if(pro.Move_Up_Date_New__c != null){
                pro.Days_Vacant1__c =  pro.Move_Up_Date_New__c.daysBetween(System.today());
            }else {
                pro.Days_Vacant1__c = null;
            }
        }
        
        update projectList;
    }   
    
    global void finish(Database.BatchableContext BC) { 
    }
}
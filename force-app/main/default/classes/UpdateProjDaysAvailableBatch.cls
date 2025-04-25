global class UpdateProjDaysAvailableBatch implements  Database.Batchable<sObject>{
 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String stage='CLOSED';
        return Database.getQueryLocator(
            'SELECT ID,Make_Available__c,Sales_Status__c,Days_Available_TODAY_Make_Available__c FROM Project__c WHERE Sales_Status__c = \'Available Now/PE Released\' AND Make_Available__c != null AND RecordType.Name =\'Renovation\'' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Project__c> projectList){
        
        List<Project__c> projListToUpdate = new List<Project__c>();
        for (Project__c proj : projectList) {
            proj.Days_Available_TODAY_Make_Available__c = proj.Make_Available__c.daysBetween(Date.today());
            projListToUpdate.add(proj);
        }
        
        if(projListToUpdate.size() > 0){
            update projListToUpdate;
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug('<-- process Finished -->');
    }  
}
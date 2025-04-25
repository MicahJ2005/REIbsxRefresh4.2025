public class ApplicationTriggerHandler {
    public static void beforeInsert(List<Application__c> newList){
        Set<Id> idSet = new Set<Id>();
       /* 
        for(Application__c app : [SELECT Id, Project__c FROM Application__c WHERE Project__c != NULL]){
            idSet.add(app.Project__c);
        }
        
        for(Application__c app : newList){
            if(app.Project__c != NULL){
                if(idSet.contains(app.Project__c)){
                    app.addError('You cannot use this Project as it is already associated with another Application.');
                }
            }
        }*/
    }
    
    public static void beforeUpdate(List<Application__c> newList){
        Set<Id> projIdSet = new Set<Id>();
        /*
        for(Application__c app : newList){
            if(app.Project__c != NULL){
                projIdSet.add(app.Project__c);
            }
        }
        Set<Id> idSet = new Set<Id>();
        
        for(Application__c app : [SELECT Id, Project__c FROM Application__c WHERE Id NOT IN : newList AND Project__c IN: projIdSet]){
            idSet.add(app.Project__c);
        }
        
        for(Application__c app : newList){
            if(app.Project__c != NULL){
                if(idSet.contains(app.Project__c)){
                    app.addError('You cannot use this Project as it is already associated with another Application.');
                }
            }
        }
*/
    }
}
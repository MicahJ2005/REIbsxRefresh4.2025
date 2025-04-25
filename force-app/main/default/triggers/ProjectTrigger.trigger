trigger ProjectTrigger on Project__c (before insert,before update,before delete, after update, after insert) {
    
    
    if(trigger.isAfter && trigger.IsInsert){
        ProjectTriggerHandler.AfterInsert(Trigger.new);
    }
    
    if(trigger.isBefore && trigger.IsInsert){
        ProjectTriggerHandler.beforeInsert(Trigger.new);
    }
    
    if(trigger.isBefore && trigger.IsUpdate){
        ProjectTriggerHandler.calculateInvestmentProperty(Trigger.new,Trigger.oldMap);
    }
    
    
}
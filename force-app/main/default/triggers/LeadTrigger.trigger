trigger LeadTrigger on Lead (After Update, before Update, after insert,before insert) {
    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.onAfterUpdate(Trigger.New, Trigger.oldMap);
        LeadTriggerHandler.updateOpportunity(Trigger.New,Trigger.OldMap);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        LeadTriggerHandler.onBeforeUpdate(Trigger.New,Trigger.OldMap);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.onAfterInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        LeadTriggerHandler.onBeforeInsert(Trigger.New);
    }
    
}